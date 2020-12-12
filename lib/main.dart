import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmgr/data-parsers/cpu.dart';
import 'package:taskmgr/layout.dart';
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
        StreamProvider.value(
          value: CPUInfo.createStream(),
          // initialData: ,
        )
      ],
      child: MaterialApp(
        title: 'Task Manager',
        builder: (context, child) => Layout(
          child: child,
        ),
        theme: ThemeData(
          primaryColor: Colors.blue,
          accentColor: Colors.blue,
          colorScheme: ColorScheme.dark(),
        ),
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => UnknownPage(),
          );
        },
        home: Layout(),
      ),
    );
  }
}
