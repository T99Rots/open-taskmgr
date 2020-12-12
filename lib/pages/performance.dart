import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:taskmgr/data-parsers/cpu.dart';

class PerformancePage extends StatefulWidget {
  PerformancePage({Key key}) : super(key: key);

  @override
  _PerformancePageState createState() => _PerformancePageState();
}

class PerformanceTabInfo {
  final String title;
  final String line2;
  final String line3;
  final Color color;
  PerformanceTabInfo({
    this.title,
    this.line2,
    this.line3,
    this.color,
  });
}

Map<int, CoreLayout> coreCountGraphLayoutMap = {
  1: CoreLayout(1, 1),
  2: CoreLayout(1, 2),
  3: CoreLayout(1, 3),
  4: CoreLayout(2, 2),
  6: CoreLayout(2, 3),
  8: CoreLayout(2, 4),
  9: CoreLayout(3, 3),
  12: CoreLayout(3, 4),
  15: CoreLayout(3, 5),
  16: CoreLayout(4, 4),
  20: CoreLayout(4, 5),
  24: CoreLayout(4, 6),
  25: CoreLayout(5, 5),
  28: CoreLayout(4, 7),
  30: CoreLayout(5, 6),
  32: CoreLayout(4, 8),
  35: CoreLayout(5, 7),
  // 36: CoreLayout(6, 6),
  40: CoreLayout(5, 8),
  // 42: CoreLayout(6, 7),
  45: CoreLayout(5, 9),
  48: CoreLayout(6, 8),
  54: CoreLayout(6, 9),
  56: CoreLayout(7, 8),
  63: CoreLayout(7, 9),
  70: CoreLayout(7, 10),
  77: CoreLayout(7, 11),
  80: CoreLayout(8, 10),
  88: CoreLayout(8, 11),
  96: CoreLayout(8, 12),
  99: CoreLayout(9, 11),
  108: CoreLayout(9, 12),
  117: CoreLayout(9, 13),
  120: CoreLayout(10, 12),
  130: CoreLayout(10, 13),
};

class CoreLayout {
  final int x;
  final int y;
  CoreLayout(this.y, this.x);

  factory CoreLayout.fromCount (int count) {
    final int max = coreCountGraphLayoutMap.keys.last;
    if(count <= max) {
      for(int i = count; i < max; i++) {
        if(coreCountGraphLayoutMap.containsKey(i)) {
          return coreCountGraphLayoutMap[i];
        }
      }
    }
    final int x = coreCountGraphLayoutMap[max].x;
    return CoreLayout((count / x).ceil(), x);
  }
}

class _PerformancePageState extends State<PerformancePage> with TickerProviderStateMixin {
  List<double> cpuUsage = List.generate(61, (index) => 0);
  List<List<double>> cpuCoreUsageHistory;
  StreamSubscription subscription;
  CPUInfo info;

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  void initState() {
    super.initState();
    subscription = CPUInfo.createStream().listen((event) {
      if(event != null) {
        if(cpuCoreUsageHistory == null) {
          cpuCoreUsageHistory = List.generate(event.threads, (_) => List.generate(61, (_) => 0));
        }

        setState(() {
          info = event;
          cpuUsage.add(info.usage * 100);
          cpuUsage.removeAt(0);
          for(int i = 0; i < cpuCoreUsageHistory.length; i++) {
            cpuCoreUsageHistory[i].add(info.processors[i].usage * 100);
            cpuCoreUsageHistory[i].removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() { 
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if(info == null) return Center(
      child: CircularProgressIndicator(),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        children: [
          Container(
            width: 340,
            child: Column(
              children: [
                Container(
                  // color: Colors.grey,
                  child: Column(
                    children: [
                      PerformanceTabInfo(
                        title: 'CPU',
                        line2: '${(info.usage * 100).toInt() ?? 0}% ${(info.cpuMHz / 1000).toStringAsPrecision(3)}GHz',
                        color: Colors.blue
                      ),
                      PerformanceTabInfo(
                        title: 'Memory',
                        line2: '43.0/64.0 GB (76%)',
                        color: Colors.purple
                      ),
                      PerformanceTabInfo(
                        title: 'Disk /dev/sda',
                        line2: 'SSD',
                        line3: '3%',
                        color: Colors.green
                      ),
                      PerformanceTabInfo(
                        title: 'Ethernet',
                        line2: 'S: 22.4 R: 843 Mbps',
                        color: Colors.orange
                      ),
                      PerformanceTabInfo(
                        title: 'GPU 0',
                        line2: 'NVIDIA GeForce RTX 3090',
                        line3: '0% (50C)',
                        color: Colors.blue
                      ),
                    ].map<Widget>((info) => ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: info.color,
                            width: 2
                          ),
                          // color: Theme.of(context).backgroundColor,
                        ),
                        width: 80,
                        child: LineChart(
                          mainData(
                            cpuUsage,
                            color: info.color,
                            tiny: true
                          ),
                          swapAnimationDuration: Duration.zero,
                        ),
                      ),
                      title: Text(info.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(info.line2 != null) Text(info.line2),
                          if(info.line3 != null) Text(info.line3)
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {},
                    )).toList()
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CPU',
                        style: TextStyle(
                          fontSize: 24
                        ),
                      ),
                      Text(
                        info.modelName
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '% Utilization over 60 seconds'
                    ),
                  ),
                  Expanded(child: Container(
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Builder(builder: (context) {
                          final n = info.threads;
                          final layout = CoreLayout.fromCount(n);

                          return Column(
                            children: List.generate(layout.y, (y) => Expanded(
                              child: Row(
                                children: List.generate(layout.x, (x) {
                                  final int coreId = layout.x*y+x;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: x < 1?0:3,
                                        right: x+1 < layout.x?3:0,
                                        top: y < 1?0:3,
                                        bottom: y+1 < layout.y?3:0,
                                      ),
                                      child: coreId < info.threads && coreId < n?Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.blue, width: 2)
                                        ),
                                        child:  ClipRect(
                                          child: LineChart(
                                            mainData(cpuCoreUsageHistory[coreId]),
                                            swapAnimationDuration: Duration.zero,
                                          ),
                                        )
                                      ): coreId < n? Container(color: Colors.blue,): null,
                                    ),
                                  );
                                }),
                              ),
                            )),
                          );
                        })
                        
                        // DecoratedBox(
                        //   decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.grey[700], width: 2)
                        //   ),
                        //   child: ClipRect(
                        //     child: LineChart(
                        //       mainData(),
                        //       swapAnimationDuration: Duration.zero,
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      height: 170,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 300,
                                child: Table(
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: TableDatePoint(
                                            title: 'Utilization',
                                            data: '${(info.usage * 100).toInt()}%',
                                          ),
                                        ),
                                        TableCell(
                                          child: TableDatePoint(
                                            title: 'Speed',
                                            data: '${(info.cpuMHz / 1000).toStringAsPrecision(3)} GHz',
                                          ),
                                        ),
                                        TableCell(child: Container(),)
                                      ]
                                    ),
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: TableDatePoint(
                                            title: 'Processes',
                                            data: '242',
                                          ),
                                        ),
                                        TableCell(
                                          child: TableDatePoint(
                                            title: 'Threads',
                                            data: '3447',
                                          ),
                                        ),
                                        TableCell(
                                          child: TableDatePoint(
                                            title: 'Handles',
                                            data: '103664',
                                          ),
                                        )
                                      ]
                                    )
                                  ],
                                ),
                              ),
                              TableDatePoint(
                                title: 'Up time',
                                data: '183:00:00:00',
                              ),
                            ],
                          ),
                          Container(
                            width: 200,
                            child: Table(
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('Base speed:')
                                    ),
                                    TableCell(
                                      child: Text('2.30GHz')
                                    )
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('Sockets:')
                                    ),
                                    TableCell(
                                      child: Text('1')
                                    )
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('Cores:')
                                    ),
                                    TableCell(
                                      child: Text(info.cores.toString())
                                    )
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('Threads:')
                                    ),
                                    TableCell(
                                      child: Text(info.threads.toString())
                                    )
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('Virtualization:')
                                    ),
                                    TableCell(
                                      child: Text('Enabled')
                                    )
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('L1 cache:')
                                    ),
                                    TableCell(
                                      child: Text('2048 KB')
                                    )
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('L2 cache:')
                                    ),
                                    TableCell(
                                      child: Text('8 MB')
                                    )
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Text('L3 cache:')
                                    ),
                                    TableCell(
                                      child: Text('32 MB')
                                    )
                                  ]
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<FlSpot> mapPoints (List<double> inp) {
    final List<FlSpot> value = [];

    for(int i = 0; i < inp.length; i++) {
      value.add(FlSpot(i.toDouble(), inp[i]));
    }

    return value;
  }

  LineChartData mainData(List<double>data,{Color color = Colors.blue, bool tiny = false}) {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: !tiny,
        drawVerticalLine: true,
        checkToShowHorizontalLine: (index) => index % 10 == 0,
        checkToShowVerticalLine: (index) => index % 10 == 0,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[700],
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[700],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 60,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: mapPoints(data),
          isCurved: false,
          curveSmoothness: 0.6,
          preventCurveOverShooting: true,
          colors: [color],
          barWidth: tiny?1:2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: [color.withOpacity(0.3)],
          ),
        ),
      ],
    );
  }
}

class TableDatePoint extends StatelessWidget {
  final String title;
  final String data;
  const TableDatePoint({Key key, this.title, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              
            ),
          ),
          Text(
            data,
            style: TextStyle(
              fontSize: 20
            ),
          )
        ],
      ),
    );
  }
}