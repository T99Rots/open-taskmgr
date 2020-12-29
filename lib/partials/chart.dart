import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StyledLineChart extends StatelessWidget {
  final bool gridLines;
  final List<double> dataPoints;
  final Color color;
  final double barWidth;

  const StyledLineChart({
    Key key,
    @required this.dataPoints,
    this.gridLines = true,
    this.color = Colors.blue,
    this.barWidth = 2
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        gridData: FlGridData(
          show: gridLines,
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
        maxX: 59,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: mapPoints(dataPoints),
            isCurved: false,
            curveSmoothness: 0.6,
            preventCurveOverShooting: true,
            colors: [color],
            barWidth: barWidth,
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
      ),
      swapAnimationDuration: Duration.zero,
    );
  }

  List<FlSpot> mapPoints (List<double> inp) {
    final List<FlSpot> list = [];
    final n = 60;

    final int diff = n - inp.length;

    for(int i = 0; i < n; i++) {
      if(i < diff) {
        list.add(FlSpot(i.toDouble(), 0));
      } else {
        list.add(FlSpot(i.toDouble(), inp[i - diff]));
      }
    }

    return list;
  }
}


class StackedBarChartEntry {
  final int value;
  final Color color;
  final String name;

  StackedBarChartEntry({
    this.value,
    this.color,
    this.name,
  });
}
class StackedBarChart extends StatelessWidget {
  final List<StackedBarChartEntry> data;
  final double height;

  const StackedBarChart({
    Key key,
    this.data,
    this.height = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2)
      ),
      height: height,
      child: Row(
        children: data.asMap().entries.map((entry) => Expanded(
          flex: entry.value.value,
          child: Tooltip(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            textStyle: TextStyle(
              fontSize: 16,
              color: Colors.white
            ),
            verticalOffset: -20,
            message: entry.value.name,
            child: Container(
              decoration: BoxDecoration(
                border: entry.key == data.length - 1? null: Border(
                  right: BorderSide(color: Colors.purple.withOpacity(0.5), width: 2)
                ),
                color: entry.value.color
              ),
            )
          )
        )).toList()
      ),
    );
  }
}