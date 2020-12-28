import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taskmgr/models/performance/cpu.dart';
import 'package:taskmgr/models/performance/memory.dart';
// import 'package:taskmgr/models/performance/cpu.dart';
// import 'package:taskmgr/models/performance/disk.dart';
// import 'package:taskmgr/models/performance/memory.dart';
// import 'package:taskmgr/models/performance/network.dart';
// import 'package:taskmgr/models/utils.dart';

enum PerformanceTab {
  CPU,
  Memory,
  Disks,
  Network
}
class PerformanceModel extends ChangeNotifier {
  final int historyLength;
  final CPU cpu;
  final Memory memory;
  final Duration updateInterval;
  Timer _timer;
  bool _loaded = false;
  PerformanceTab _tab = PerformanceTab.CPU;
  bool _showThreadGraphs = false;

  bool get loaded => _loaded;
  PerformanceTab get tab => _tab;
  bool get showThreadGraphs => _showThreadGraphs;

  PerformanceModel({
    @required this.historyLength,
    @required this.updateInterval
  }): 
    cpu = CPU(historyLength: historyLength),
    memory = Memory(historyLength: historyLength);

  Future update() async {
    await Future.wait([
      memory.update(),
      cpu.update()
    ]);
    
    _loaded = true;
    notifyListeners();
  }

  start() {
    _timer = Timer.periodic(updateInterval, (_) => update());
    update();
  }

  stop() {
    _timer.cancel();
  }

  changeTab(PerformanceTab tab) {
    if(_tab != tab) {
      _tab = tab;
      notifyListeners();
    }
  }

  toggleShowThreadGraphs() {
    _showThreadGraphs = !_showThreadGraphs;
    notifyListeners();
  }
}