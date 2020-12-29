import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taskmgr/models/performance/performance.dart';
import 'package:taskmgr/partials/chart.dart';
import 'package:taskmgr/partials/table-data-point.dart';

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

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitHours = twoDigits(duration.inHours.remainder(24));
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${duration.inDays}:$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
}
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

class CPUTab extends StatelessWidget {
  const CPUTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PerformanceModel>();
    final cpu = model.cpu;

    return Padding(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CPU',
                    style: TextStyle(
                      fontSize: 24
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '% Utilization over 60 seconds'
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    cpu.modelName
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  model.showThreadGraphs
                    ?MdiIcons.chartLine
                    :MdiIcons.viewGridOutline
                ),
                onPressed: () {
                  model.toggleShowThreadGraphs();
                }
              )
            ],
          ),
          Expanded(child: Container(
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 5),
                child: model.showThreadGraphs? Builder(builder: (context) {
                  final n = cpu.threads.length;
                  final layout = CoreLayout.fromCount(n);

                  return Column(
                    children: List.generate(layout.y, (y) => Expanded(
                      child: Row(
                        children: List.generate(layout.x, (x) {
                          final int threadId = layout.x*y+x;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: x < 1?0:3,
                                right: x+1 < layout.x?3:0,
                                top: y < 1?0:3,
                                bottom: y+1 < layout.y?3:0,
                              ),
                              child: threadId < cpu.threads.length && threadId < n?Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue, width: 2)
                                ),
                                child:  ClipRect(
                                  child: StyledLineChart(
                                    dataPoints: cpu.threads[threadId].usageHistory.map((e) => e.totalUsage * 100).toList(),
                                  )
                                )
                              ): threadId < n? Container(color: Colors.blue,): null,
                            ),
                          );
                        }),
                      ),
                    )),
                  );
                }): Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2)
                  ),
                  child: ClipRect(
                    child: StyledLineChart(
                      dataPoints: cpu.usageHistory.map((e) => e.totalUsage * 100).toList(),
                    )
                  ),
                ),
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
                                    data: '${(cpu.usageHistory.last.totalUsage * 100).toInt()}%',
                                  ),
                                ),
                                TableCell(
                                  child: TableDatePoint(
                                    title: 'Speed',
                                    data: '${(cpu.usageHistory.last.mhz / 1000).toStringAsPrecision(3)} GHz',
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
                        data: formatDuration(Duration(seconds: cpu.uptime.toInt())),
                      ),
                    ],
                  ),
                  Container(
                    width: 200,
                    child: Table(
                      children: [
                        // TableRow(
                        //   children: [
                        //     TableCell(
                        //       child: Text('Base speed:')
                        //     ),
                        //     TableCell(
                        //       child: Text('2.30GHz')
                        //     )
                        //   ]
                        // ),
                        // TableRow(
                        //   children: [
                        //     TableCell(
                        //       child: Text('Sockets:')
                        //     ),
                        //     TableCell(
                        //       child: Text('1')
                        //     )
                        //   ]
                        // ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Cores:')
                            ),
                            TableCell(
                              child: Text(cpu.cores.toString())
                            )
                          ]
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Threads:')
                            ),
                            TableCell(
                              child: Text(cpu.threads.length.toString())
                            )
                          ]
                        ),
                        // TableRow(
                        //   children: [
                        //     TableCell(
                        //       child: Text('Virtualization:')
                        //     ),
                        //     TableCell(
                        //       child: Text('Enabled')
                        //     )
                        //   ]
                        // ),
                        // TableRow(
                        //   children: [
                        //     TableCell(
                        //       child: Text('L1 cache:')
                        //     ),
                        //     TableCell(
                        //       child: Text('2048 KB')
                        //     )
                        //   ]
                        // ),
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
    );
  }
}