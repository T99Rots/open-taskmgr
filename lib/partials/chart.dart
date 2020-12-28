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