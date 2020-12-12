import 'package:flutter/material.dart';
import 'package:taskmgr/models/performance/performance.dart';

class GlobalModel extends ChangeNotifier {
  int _tabIndex = 0;
  PerformanceModel _performanceModel;
  

  int get tabIndex => _tabIndex;
}