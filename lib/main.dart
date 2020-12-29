import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmgr/layout.dart';
import 'package:taskmgr/models/performance/performance.dart';
import 'package:taskmgr/pages/unknown.dart';

void main() {
  runApp(TaskManager());
}

class TaskManager extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PerformanceModel(historyLength: 60, updateInterval: Duration(seconds: 1))..start())
      ],
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          primaryColor: Colors.blue,
          accentColor: Colors.blue,
          colorScheme: ColorScheme.dark(),
        ),
        home: Layout()
      ),
    );
  }
}
