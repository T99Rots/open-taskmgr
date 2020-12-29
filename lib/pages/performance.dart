import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmgr/models/performance/memory.dart';
import 'package:taskmgr/models/performance/performance.dart';
import 'package:taskmgr/pages/performace/cpu.dart';
import 'package:taskmgr/pages/performace/memory.dart';
import 'package:taskmgr/partials/chart.dart';
class PerformancePage extends StatefulWidget {
  PerformancePage({Key key}) : super(key: key);

  @override
  _PerformancePageState createState() => _PerformancePageState();
}
class _PerformancePageState extends State<PerformancePage> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() { 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PerformanceModel>();

    if(!model.loaded) return Center(
      child: CircularProgressIndicator(),
    );

    final cpuEntry = model.cpu.usageHistory.last;
    final memoryEntry = model.memory.usageHistory.last;

    String kbToGb(int kb) => (kb / (1024 * 1024)).toStringAsFixed(1);

    double getMemoryUsagePercentage(MemoryInfoEntry entry) {
      return ((model.memory.totalMemory - entry.memAvailable) / model.memory.totalMemory)*100;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        children: [
          Container(
            width: 280,
            child: Column(
              children: [
                Container(
                  // color: Colors.grey,
                  child: Column(
                    children: [
                      TabTile(
                        title: 'CPU',
                        line2: '${(cpuEntry.totalUsage * 100).toInt() ?? 0}% ${(cpuEntry.mhz / 1000).toStringAsPrecision(3)}GHz',
                        color: Colors.blue,
                        onTab: () => model.changeTab(PerformanceTab.CPU),
                        selected: model.tab == PerformanceTab.CPU,
                        graphData: model.cpu.usageHistory.map((e) => e.totalUsage * 100).toList(),
                      ),
                      TabTile(
                        title: 'Memory',
                        line2: '${kbToGb(model.memory.totalMemory - memoryEntry.memAvailable)}/${kbToGb(model.memory.totalMemory)} GB ' 
                          +'(${getMemoryUsagePercentage(memoryEntry).floor()}%)',
                        color: Colors.purple,
                        onTab: () => model.changeTab(PerformanceTab.Memory),
                        selected: model.tab == PerformanceTab.Memory,
                        graphData: model.memory.usageHistory.map(getMemoryUsagePercentage).toList(),
                      ),
                      TabTile(
                        title: 'Disk /dev/sda',
                        line2: 'SSD',
                        line3: '3%',
                        color: Colors.green,
                        onTab: () => model.changeTab(PerformanceTab.Disks),
                        selected: model.tab == PerformanceTab.Disks,
                      ),
                      TabTile(
                        title: 'Ethernet',
                        line2: 'S: 22.4 R: 843 Mbps',
                        color: Colors.orange,
                        onTab: () => model.changeTab(PerformanceTab.Network),
                        selected: model.tab == PerformanceTab.Network,
                      ),
                      // TabTile(
                      //   title: 'GPU 0',
                      //   line2: 'NVIDIA GeForce RTX 3090',
                      //   line3: '0% (50C)',
                      //   color: Colors.blue,
                      //   onTab: () => model.changeTab(PerformanceTab.CPU),
                      // ),
                    ]
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: getTabWidget(model.tab)
          )
        ],
      ),
    );
  }

  Widget getTabWidget(PerformanceTab tab) {
    switch(tab) {
      case PerformanceTab.CPU:
        return CPUTab();
      case PerformanceTab.Disks:
        return Container(child: Center(child: Text('Disks')));
      case PerformanceTab.Memory:
        return MemoryTab();
      case PerformanceTab.Network:
        return Container(child: Center(child: Text('Network')));
      default:
        return Container(child: Center(child: Text('Tab not found')));
    }
  }
}

class TabTile extends StatelessWidget {
  final String title;
  final String line2;
  final String line3;
  final Color color;
  final VoidCallback onTab;
  final bool selected;
  final List<double> graphData;

  const TabTile({
    Key key,
    this.title,
    this.line2,
    this.line3,
    this.color,
    this.onTab,
    this.selected = false,
    this.graphData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      leading: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 2
          ),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        width: 80,
        child: graphData == null? null: StyledLineChart(
          dataPoints: graphData,
          gridLines: false,
          color: color,
        )
      ),
      title: Text(title, style: TextStyle(color: Colors.white),),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(line2 != null) Text(line2, style: TextStyle(color: Colors.white)),
          if(line3 != null) Text(line3, style: TextStyle(color: Colors.white))
        ],
      ),
      isThreeLine: true,
      onTap: selected? null: onTab,
    );
  }
}