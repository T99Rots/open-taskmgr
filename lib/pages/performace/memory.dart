import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmgr/models/performance/memory.dart';
import 'package:taskmgr/models/performance/performance.dart';
import 'package:taskmgr/partials/chart.dart';
import 'package:taskmgr/partials/table-data-point.dart';

class MemoryTab extends StatelessWidget {
  const MemoryTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PerformanceModel>();
    final memory = model.memory;

    final MemoryInfoEntry lastEntry = memory.usageHistory.last;

    final int free = lastEntry.memFree;
    final int used = memory.totalMemory - lastEntry.memAvailable;
    final int standby = lastEntry.memAvailable - lastEntry.memFree;

    double getMemoryUsagePercentage(MemoryInfoEntry entry) {
      return ((memory.totalMemory - entry.memAvailable) / memory.totalMemory)*100;
    }

    String kbToGb(int kb) => (kb / (1024 * 1024)).toStringAsFixed(1);

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
                    'Memory',
                    style: TextStyle(
                      fontSize: 24
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Memory usage',
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${kbToGb(memory.totalMemory)} GB',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          Expanded(child: Container(
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple, width: 2)
                  ),
                  child: ClipRect(
                    child: StyledLineChart(
                      dataPoints: memory.usageHistory.map(getMemoryUsagePercentage).toList(),
                      color: Colors.purple,
                    )
                  ),
                ),
              ),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 5),
            child: Text('60 seconds'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text('Memory composition'),
          ),
          StackedBarChart(
            data: [
              StackedBarChartEntry(
                color: Colors.purple.withOpacity(0.3),
                value: used,
                name: 
                  'In use (${used ~/ 1024}MB)\n\n'
                  +'Memory used by processes, drivers or\n'
                  +'the operating system',
              ),
              StackedBarChartEntry(
                color: Colors.purple.withOpacity(0.05),
                value: standby,
                name: 
                  'Standby (${standby ~/ 1024}MB)\n\n'
                  +'Memory that contains cached data\n'
                  +'and code that is not actively in use',
              ),
              StackedBarChartEntry(
                color: Colors.transparent,
                value: free,
                name: 
                  'Free (${free ~/ 1024}MB)\n\n'
                  +'Memory that is not in use\n'
                  +'and will be used first when\n'
                  +'processes, drivers or the\n'
                  +'operating system need memory',
              )
            ],
          ),
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
                        width: 280,
                        child: Table(
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                  child: TableDatePoint(
                                    title: 'In use',
                                    data: '${kbToGb(memory.totalMemory - lastEntry.memAvailable)} GB',
                                  ),
                                ),
                                TableCell(
                                  child: TableDatePoint(
                                    title: 'Available',
                                    data: '${kbToGb(lastEntry.memAvailable)} GB',
                                  ),
                                ),
                              ]
                            ),
                            TableRow(
                              children: [
                                TableCell(
                                  child: TableDatePoint(
                                    title: 'Committed',
                                    data: '${kbToGb(lastEntry.committedAs)}/${kbToGb(lastEntry.commitLimit)} GB',
                                  ),
                                ),
                                TableCell(
                                  child: TableDatePoint(
                                    title: 'Cached',
                                    data: '${kbToGb(lastEntry.cached)} GB',
                                  ),
                                ),
                               ]
                            ),
                            // TableRow(
                            //   children: [
                            //     TableCell(
                            //       child: TableDatePoint(
                            //         title: 'Paged',
                            //         data: '${lastEntry.committedAs}/${lastEntry.commitLimit} KB',
                            //       ),
                            //     ),
                            //     TableCell(
                            //       child: TableDatePoint(
                            //         title: 'Cached',
                            //         data: '${lastEntry.cached} KB',
                            //       ),
                            //     ),
                            //    ]
                            // )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 280,
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Speed:')
                            ),
                            TableCell(
                              child: Text('3600 MHz')
                            )
                          ]
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Slots used:')
                            ),
                            TableCell(
                              child: Text('4 of 4')
                            )
                          ]
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Form factor:')
                            ),
                            TableCell(
                              child: Text('DDR4')
                            )
                          ]
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Hardware reserved:')
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