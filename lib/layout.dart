import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmgr/models/global.dart';
import 'package:taskmgr/pages/performance.dart';
import 'package:taskmgr/pages/processes.dart';

class Layout extends StatefulWidget {
  final Widget child;
  const Layout({Key key, this.child}) : super(key: key);

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with TickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _controller,
        tabs: [
          Tab(text: 'Processes'),
          Tab(text: 'Performance'),
          // Tab(text: 'App history'),
          Tab(text: 'Startup'),
          // Tab(text: 'Users'),
          // Tab(text: 'Details'),
          Tab(text: 'Services'),
          Tab(text: 'Settings'),
        ],
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: [
          ProcessesPage(),
          PerformancePage(),
          Container(),
          Container(),
          Container(),
          // Container(),
          // Container(),
        ],
      ),
    );
  }
}