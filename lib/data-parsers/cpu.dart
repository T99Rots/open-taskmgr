import 'dart:developer';
import 'dart:io';
import 'dart:async';

class CoreStat {
  final int user;
  final int nice;
  final int system;
  final int idle;
  final int iowait;
  final int irq;
  final int softirq;
  final int steal;
  final int guest;
  final int guest_nice;

  final int totalIdle;
  final int total;

  CoreStat(
    this.user,
    this.nice,
    this.system,
    this.idle,
    this.iowait,
    this.irq,
    this.softirq,
    this.steal,
    this.guest,
    this.guest_nice
  ):
    totalIdle = idle + iowait,
    total = idle + iowait + user + nice + system + irq + softirq + steal;
}

class CoreInfo {
  final int processor;
  final String vendorId;
  final int cpuFamily;
  final int model;
  final String modelName;
  final int stepping;
  final int microcode;
  final double cpuMHz;
  final String cacheSize;
  final int physicalId;
  final int siblings;
  final int coreId;
  final int cpuCores;
  final int apicid;
  final int initialApicid;
  final bool fpu;
  final bool fpuException;
  final int cpuidLevel;
  final bool wp;
  final List<String> flags;
  final List<String> bugs;
  final double bogomips;
  final String tlbSize;
  final int clflushSize;
  final int cacheAlignment;
  final String addressSizes;
  final String powerManagement;
  final double usage;

  CoreInfo({
    this.processor,
    this.vendorId,
    this.cpuFamily,
    this.model,
    this.modelName,
    this.stepping,
    this.microcode,
    this.cpuMHz,
    this.cacheSize,
    this.physicalId,
    this.siblings,
    this.coreId,
    this.cpuCores,
    this.apicid,
    this.initialApicid,
    this.fpu,
    this.fpuException,
    this.cpuidLevel,
    this.wp,
    this.flags,
    this.bugs,
    this.bogomips,
    this.tlbSize,
    this.clflushSize,
    this.cacheAlignment,
    this.addressSizes,
    this.powerManagement,
    this.usage,
  });
}

class CPUInfo {
  final List<CoreInfo> processors;
  final double cpuMHz;
  final int cores;
  final int threads;
  final String vendorId;
  final String modelName;
  final int microcode;
  final bool fpu;
  final bool fpuException;
  final List<String> flags;
  final List<String> bugs;
  final double bogomips;
  final String powerManagement;
  final double usage;

  CPUInfo({
    this.processors,
    this.usage
  }) : 
    vendorId = processors[0].vendorId,
    modelName = processors[0].modelName,
    microcode = processors[0].microcode,
    fpu = processors[0].fpu,
    fpuException = processors[0].fpuException,
    flags = processors[0].flags,
    bugs = processors[0].bugs,
    bogomips = processors[0].bogomips,
    powerManagement = processors[0].powerManagement,
    cores = processors[0].cpuCores,
    threads = processors[0].siblings,
    cpuMHz = processors.fold(0, (max, processor) => processor.cpuMHz > max? processor.cpuMHz: max);

  static final File _cpuinfo = new File('/proc/cpuinfo');
  static final File _stat = new File('/proc/stat');

  static Stream<CPUInfo> createStream () {
    final controller = StreamController<CPUInfo>();
    List<CoreStat> coreStats;

    final timer = Timer.periodic(Duration(seconds: 1), (_) async {
      final List<String> results = await Future.wait([
        _cpuinfo.readAsString(),
        _stat.readAsString()
      ]);

      final String cpuInfo = results[0];
      final String stat = results[1];

      final List<CoreStat> statList = stat
        .split(RegExp(r"\n", multiLine: true))
        .where((str) => str.startsWith('cpu'))
        .map<CoreStat>((str) {
          final statParts = str.split(RegExp(r"\s+"));
          return CoreStat(
            int.parse(statParts[1]),
            int.parse(statParts[2]),
            int.parse(statParts[3]),
            int.parse(statParts[4]),
            int.parse(statParts[5]),
            int.parse(statParts[6]),
            int.parse(statParts[7]),
            int.parse(statParts[8]),
            int.parse(statParts[9]),
            int.parse(statParts[10]),
          );
        })
        .toList();

      double cpuUsage;
      List<double> coresUsage;

      if(coreStats != null) {
        final List<double> usageAll = [];

        for(int i = 0; i < statList.length; i++) {
          final int totalDifference = statList[i].total - coreStats[i].total;
          final int idleDifference = statList[i].totalIdle - coreStats[i].totalIdle;
          usageAll.add((totalDifference - idleDifference) / totalDifference);
        }

        cpuUsage = usageAll.removeAt(0);
        coresUsage = usageAll;
      } else {
        cpuUsage = 0;
        coresUsage = List.generate(statList.length - 1, (_) => 0);
      }

      coreStats = statList;

      final List<String> coreInfoStringList = cpuInfo
        .split(RegExp(r"\n\n", multiLine: true))
        .where((str) => str.length > 0)
        .toList();

      final List<Map> coreInfoMapList= coreInfoStringList.map((coreString) => Map.fromEntries(coreString
        .split(RegExp(r"\n", multiLine: true))
        .map((string) => string.split(RegExp(r"\s*:\s*")))
        .map((List<String> list) => MapEntry(list[0], list[1])).toList()
      )).toList();
      
      bool parseBool (String str) {
        switch(str.toLowerCase().trim()) {
          case 'yes':
            return true;
          case 'no':
            return false;
          case 'true':
            return true;
          case 'false':
            return false;
          case 'enabled':
            return true;
          case 'disabled':
            return false;
        }
      }

      final List<CoreInfo> processors = [];
      
      for(int i = 0; i < coreInfoMapList.length; i++) {
        final coreInfoMap = coreInfoMapList[i];

        processors.add(CoreInfo(
          processor: int.parse(coreInfoMap['processor']),
          vendorId: coreInfoMap['vendor_id'],
          cpuFamily: int.parse(coreInfoMap['cpu family']),
          model: int.parse(coreInfoMap['model']),
          modelName: coreInfoMap['model name'],
          stepping: int.parse(coreInfoMap['stepping']),
          microcode: int.parse(coreInfoMap['microcode']),
          cpuMHz: double.parse(coreInfoMap['cpu MHz']),
          cacheSize: coreInfoMap['cache size'],
          physicalId: int.parse(coreInfoMap['physical id']),
          siblings: int.parse(coreInfoMap['siblings']),
          coreId: int.parse(coreInfoMap['core id']),
          cpuCores: int.parse(coreInfoMap['cpu cores']),
          apicid: int.parse(coreInfoMap['apicid']),
          initialApicid: int.parse(coreInfoMap['initial apicid']),
          fpu: parseBool(coreInfoMap['fpu']),
          fpuException: parseBool(coreInfoMap['fpu_exception']),
          cpuidLevel: int.parse(coreInfoMap['cpuid level']),
          wp: parseBool(coreInfoMap['wp']),
          flags: coreInfoMap['flags'].split(RegExp(r"\s+")),
          bugs: coreInfoMap['bugs'].split(RegExp(r"\s+")),
          bogomips: double.parse(coreInfoMap['bogomips']),
          tlbSize: coreInfoMap['TLB size'],
          clflushSize: int.parse(coreInfoMap['clflush size']),
          cacheAlignment: int.parse(coreInfoMap['cache_alignment']),
          addressSizes: coreInfoMap['address sizes'],
          powerManagement: coreInfoMap['power management'],
          usage: coresUsage[i]
        ));
      }

      controller.add(CPUInfo(
        processors: processors,
        usage: cpuUsage
      ));
    });

    controller.onCancel = () => timer.cancel();
    return controller.stream;
  }
}