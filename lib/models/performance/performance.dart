import 'package:flutter/material.dart';
// import 'package:taskmgr/models/performance/cpu.dart';
import 'package:taskmgr/models/performance/disk.dart';
import 'package:taskmgr/models/performance/memory.dart';
import 'package:taskmgr/models/performance/network.dart';
import 'package:taskmgr/models/utils.dart';

class PerformanceModel extends ChangeNotifier {
  MemoryModel _memory;
  CPUModel _cpu;
  List<NetworkInterfaceModel> _networkInterfaces;
  List<DiskModel> _disks;



  Stream<PerformanceModel> createStream () {

  }
}

class CPUModel {
  List<ProcessorModel> _processors;
}

class ProcessorUsageHistoryModel {

}

class ProcessorModel {
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
  final String power;
  final ProcessorStatsModel stats;
  final List<ProcessorUsageHistoryModel> history;

  ProcessorModel({
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
    this.power,
    this.stats,
    this.history
  });

  factory ProcessorModel.fromProcessorTextAndStats (
    String processorText,
    ProcessorStatsModel stats
  ) {
    final Map<String, String> processorInfoMap = Map.fromEntries(processorText
      .split(RegExp(r"\n", multiLine: true))
      .map((string) => string.split(RegExp(r"\s*:\s*")))
      .map((List<String> list) => MapEntry(list[0], list[1])).toList()
    );

    return ProcessorModel(
      processor: int.parse(processorInfoMap['processor']),
      vendorId: processorInfoMap['vendor_id'],
      cpuFamily: int.parse(processorInfoMap['cpu family']),
      model: int.parse(processorInfoMap['model']),
      modelName: processorInfoMap['model name'],
      stepping: int.parse(processorInfoMap['stepping']),
      microcode: int.parse(processorInfoMap['microcode']),
      cpuMHz: double.parse(processorInfoMap['cpu MHz']),
      cacheSize: processorInfoMap['cache size'],
      physicalId: int.parse(processorInfoMap['physical id']),
      siblings: int.parse(processorInfoMap['siblings']),
      coreId: int.parse(processorInfoMap['core id']),
      cpuCores: int.parse(processorInfoMap['cpu cores']),
      apicid: int.parse(processorInfoMap['apicid']),
      initialApicid: int.parse(processorInfoMap['initial apicid']),
      fpu: parseBool(processorInfoMap['fpu']),
      fpuException: parseBool(processorInfoMap['fpu_exception']),
      cpuidLevel: int.parse(processorInfoMap['cpuid level']),
      wp: parseBool(processorInfoMap['wp']),
      flags: processorInfoMap['flags'].split(RegExp(r"\s+")),
      bugs: processorInfoMap['bugs'].split(RegExp(r"\s+")),
      bogomips: double.parse(processorInfoMap['bogomips']),
      tlbSize: processorInfoMap['TLB size'],
      clflushSize: int.parse(processorInfoMap['clflush size']),
      cacheAlignment: int.parse(processorInfoMap['cache_alignment']),
      addressSizes: processorInfoMap['address sizes'],
      power: processorInfoMap['power'],
      stats: stats
    );
  }

  factory ProcessorModel.copyWithHistory () {
    
  }
}

class ProcessorStatsModel {
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

  ProcessorStatsModel(
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
  );

  factory ProcessorStatsModel.fromCPUStatsLine(String string) {
    final statParts = string.split(RegExp(r"\s+"));
    return ProcessorStatsModel(
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
  }
}