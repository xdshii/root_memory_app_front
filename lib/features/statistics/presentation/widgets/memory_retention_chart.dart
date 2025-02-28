import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/statistics/memory_analytics.dart';

class MemoryRetentionChart extends StatelessWidget {
  final List<RetentionPoint> retentionCurve;
  
  const MemoryRetentionChart({
    Key? key,
    required this.retentionCurve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 生成图表数据点
    final spots = retentionCurve.map((point) => 
      FlSpot(point.daysSinceLearn.toDouble(), point.retentionPercentage)
    ).toList();
    
    // 计算最大天数和最大保留率
    final maxDays = retentionCurve.isEmpty ? 90.0 : 
        retentionCurve.map((p) => p.daysSinceLearn).reduce((a, b) => a > b ? a : b).toDouble();
    final maxRate = retentionCurve.isEmpty ? 100.0 : 
        retentionCurve.map((p) => p.retentionPercentage).reduce((a, b) => a > b ? a : b);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 15,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (context, value) => const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            getTitles: (value) {
              if (value == 0) return '0';
              if (value == 1) return '1天';
              if (value == 7) return '1周';
              if (value == 30) return '1月';
              if (value == 90) return '3月';
              return '';
            },
            margin: 8,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            getTitles: (value) {
              if (value % 20 != 0) return '';
              return '${value.toInt()}%';
            },
            reservedSize: 28,
            margin: 12,
          ),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(showTitles: false),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.grey, width: 1),
            left: BorderSide(color: Colors.grey, width: 1),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        minX: 0,
        maxX: maxDays,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // 实际记忆曲线
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            colors: [Colors.blue],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.blue,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.0),
              ],
              gradientColorStops: [0.5, 1.0],
              gradientFrom: const Offset(0, 0),
              gradientTo: const Offset(0, 1),
            ),
          ),
          // 理论艾宾浩斯遗忘曲线（对比参考）
          LineChartBarData(
            spots: _generateEbbinghausCurve(),
            isCurved: true,
            curveSmoothness: 0.3,
            colors: [Colors.grey],
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            dashArray: [5, 5], // 虚线显示
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                if (barSpot.barIndex == 0) {
                  return LineTooltipItem(
                    '${flSpot.x.toInt()}天: ${flSpot.y.toStringAsFixed(1)}%',
                    const TextStyle(color: Colors.white),
                  );
                } else {
                  return LineTooltipItem(
                    '理论曲线: ${flSpot.y.toStringAsFixed(1)}%',
                    const TextStyle(color: Colors.white),
                  );
                }
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
  
  // 生成理论艾宾浩斯遗忘曲线
  List<FlSpot> _generateEbbinghausCurve() {
    final List<FlSpot> spots = [];
    // 艾宾浩斯遗忘曲线公式: R = e^(-t/S), 其中S是稳定性参数，t是时间
    const double stabilityFactor = 30.0; // 稳定性参数，可调整
    for (int day = 0; day <= 90; day += 5) {
      if (day == 0) {
        spots.add(const FlSpot(0, 100));
        continue;
      }
      double retention = 100 * (0.1 + 0.9 * (stabilityFactor / (day + stabilityFactor)));
      spots.add(FlSpot(day.toDouble(), retention));
    }
    return spots;
  }
}