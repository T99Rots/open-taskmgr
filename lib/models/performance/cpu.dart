import 'dart:io';
import 'package:flutter/material.dart';

bool parseBool (String str) {
  switch(str.toLowerCase().trim()) {
    case 'yes':
      return true;
    case 'no':
      return false;
    case 'true':
      return true;
    case 'false':
    default:
      return false;
  }
}
class CPU {
  final File _cpuinfoFile = new File('/proc/cpuinfo');
  final File _statFile = new File('/proc/stat');

  final List<CPUThread> threads = [];
  final List<CPUUsageEntry> usageHistory = [];
  final int historyLength;

  int cores;
  String vendorId;
  String modelName;
  int microcode;
  bool fpu;
  bool fpuException;
  List<String> flags;
  List<String> bugs;
  double bogomips;
  String powerManagement;
  String tlbSize;

  CPU({this.historyLength});
  
  Future update () async {
    final List<String> results = await Future.wait([
      _cpuinfoFile.readAsString(),
      _statFile.readAsString()
    ]);

    final String cpuInfo = results[0];
    final String stats = results[1];

    // parsing the cpu info list in to a map

    final List<String> coreInfoList = cpuInfo
      .split(RegExp(r"\n\n", multiLine: true))
      .where((str) => str.length > 0)
      .toList();

    final List<Map> coreInfoMapList = coreInfoList.map((coreString) => Map.fromEntries(coreString
      .split(RegExp(r"\n", multiLine: true))
      .map((string) => string.split(RegExp(r"\s*:\s*")))
      .map((List<String> list) => MapEntry(list[0], list[1])).toList()
    )).toList();

    // assigning general cpu info

    vendorId = coreInfoMapList.first['vendor_id'];
    modelName = coreInfoMapList.first['model name'];
    microcode = int.parse(coreInfoMapList.first['microcode']);
    cores = int.parse(coreInfoMapList.first['cpu cores']);
    fpu = parseBool(coreInfoMapList.first['fpu']);
    fpuException = parseBool(coreInfoMapList.first['fpu_exception']);
    flags = coreInfoMapList.first['flags'].split(RegExp(r"\s+"));
    bugs = coreInfoMapList.first['bugs'].split(RegExp(r"\s+"));
    bogomips = double.parse(coreInfoMapList.first['bogomips']);
    tlbSize = coreInfoMapList.first['TLB size'];
    powerManagement = coreInfoMapList.first['power management'];

    // parsing the cpu stats
   
    final List<String> statList = stats
      .split(RegExp(r"\n", multiLine: true))
      .where((str) => str.startsWith('cpu'))
      .toList();

    final cpuStats = statList.removeAt(0);

    if(threads.length != coreInfoMapList.length) {
      for(Map coreInfoMap in coreInfoMapList) {
        threads.add(CPUThread(
          id: int.parse(coreInfoMap['processor']),
          historyLength: historyLength
        ));
      }
    }

    for(int i = 0; i < statList.length; i++) {
      threads[i].update(
        mhz: double.parse(coreInfoMapList[i]['cpu MHz']),
        stats: statList[i]
      );
    }

    final double maxMhz = coreInfoMapList.fold(
      0,
      (max, thread) => double.parse(thread['cpu MHz']) > max? double.parse(thread['cpu MHz']): max
    );

    if(usageHistory.length < 1) {
      usageHistory.add(CPUUsageEntry(
        mhz: maxMhz,
        stats: cpuStats
      ));
    } else {
      usageHistory.add(CPUUsageEntry.fromPreviousEntry(
        mhz: maxMhz,
        previous: usageHistory.last,
        stats: cpuStats
      ));
    }

    if(usageHistory.length > historyLength) {
      usageHistory.removeAt(0);
    }
  }
}

class CPUThread {
  final int id;
  final List<CPUUsageEntry> usageHistory = [];
  final int historyLength;

  CPUThread({
    @required this.id,
    @required this.historyLength
  });

  void update ({
    @required double mhz,
    @required String stats
  }) {
    if(usageHistory.length < 1) {
      usageHistory.add(CPUUsageEntry(
        mhz: mhz,
        stats: stats,
      ));
    } else {
      usageHistory.add(CPUUsageEntry.fromPreviousEntry(
        mhz: mhz,
        previous: usageHistory.last,
        stats: stats,
      ));
    }
    if(usageHistory.length > historyLength) {
      usageHistory.removeAt(0);
    }
  }
}

class CPUUsageEntry {
  final double mhz;

  int user;
  int nice;
  int system;
  int idle;
  int iowait;
  int irq;
  int softirq;
  int steal;
  int guest;
  int guest_nice;

  double totalUsage;
  double kernelUsage;

  CPUUsageEntry({
    this.totalUsage = 0,
    this.kernelUsage = 0,
    @required this.mhz,
    @required String stats
  }) {
    final List<String> parts = stats.split(RegExp(r"\s+"));

    user = int.parse(parts[1]);
    nice = int.parse(parts[2]);
    system = int.parse(parts[3]);
    idle = int.parse(parts[4]);
    iowait = int.parse(parts[5]);
    irq = int.parse(parts[6]);
    softirq = int.parse(parts[7]);
    steal = int.parse(parts[8]);
    guest = int.parse(parts[9]);
    guest_nice = int.parse(parts[10]);
  }

  factory CPUUsageEntry.fromPreviousEntry({
    @required double mhz,
    @required CPUUsageEntry previous,
    @required String stats
  }) {
    final entry = CPUUsageEntry(
      mhz: mhz,
      stats: stats
    );

    final CPUUsageEntry prev = previous;

    final int totalIdle = entry.idle + entry.iowait;
    final int total = totalIdle + entry.user + entry.nice + entry.system + entry.irq + entry.softirq + entry.steal;

    final int prevTotalIdle = prev.idle + prev.iowait;
    final int prevTotal = prevTotalIdle + prev.user + prev.nice + prev.system + prev.irq + prev.softirq + prev.steal;

    final int totalDiff = total - prevTotal;
    final int idleDiff = totalIdle - prevTotalIdle;
    final int kernelDiff = entry.system - prev.system;

    entry.totalUsage = (totalDiff - idleDiff) / totalDiff;
    entry.kernelUsage = kernelDiff / totalDiff;

    return entry;
  }
}