import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/statistics/learning_statistics.dart';

class LearningTrendChart extends StatelessWidget {
  final List<DailyStudyStat> studyStats;
  final String period;
  
  const LearningTrendChart({
    Key? key,
    required this.studyStats,
    required this.period,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 根据时段筛选数据
    final filteredStats = _filterStudyStats(studyStats, period);
    
    // 计算日期间隔，决定X轴标签密度
    final interval = _calculateDateInterval(filteredStats.length);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 15,
          verticalInterval: interval.toDouble(),
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
              fontSize: 10,
            ),
            getTitles: (value) {
              if (value.toInt() % interval != 0) return '';
              if (value.toInt() >= filteredStats.length) return '';
              
              final date = filteredStats[value.toInt()].date;
              return DateFormat(period == 'week' ? 'E' : 'MM/dd').format(date);
            },
            margin: 8,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
            getTitles: (value) {
              if (value % 15 != 0) return '';
              return '${value.toInt()}分';
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
        maxX: filteredStats.length - 1.0,
        minY: 0,
        maxY: _getMaxStudyTime(filteredStats) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(filteredStats),
            isCurved: true,
            colors: [AppTheme.primaryColor],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.primaryColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
              checkToShowDot: (spot, barData) {
                return spot.x % interval == 0;
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                AppTheme.primaryColor.withOpacity(0.0),
              ],
              gradientColorStops: [0.5, 1.0],
              gradientFrom: const Offset(0, 0),
              gradientTo: const Offset(0, 1),
            ),
          ),
        ],
      ),
    );
  }
  
  List<DailyStudyStat> _filterStudyStats(List<DailyStudyStat> stats, String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'week':
        // 过去7天
        final weekStart = DateTime(now.year, now.month, now.day - 6);
        return stats.where((stat) => stat.date.isAfter(weekStart) || 
                                      stat.date.isAtSameMomentAs(weekStart))
                    .toList();
      case 'month':
        // 过去30天
        final monthStart = DateTime(now.year, now.month, now.day - 29);
        return stats.where((stat) => stat.date.isAfter(monthStart) || 
                                      stat.date.isAtSameMomentAs(monthStart))
                    .toList();
      case 'year':
        // 当年
        final yearStart = DateTime(now.year, 1, 1);
        return stats.where((stat) => stat.date.isAfter(yearStart) || 
                                      stat.date.isAtSameMomentAs(yearStart))
                    .toList();
      case 'all':
      default:
        // 所有数据
        return stats;
    }
  }
  
  List<FlSpot> _createSpots(List<DailyStudyStat> stats) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < stats.length; i++) {
      spots.add(FlSpot(i.toDouble(), stats[i].minutes.toDouble()));
    }
    
    return spots;
  }
  
  int _getMaxStudyTime(List<DailyStudyStat> stats) {
    if (stats.isEmpty) return 60; // 默认最大值
    
    return stats
        .map((stat) => stat.minutes)
        .reduce((max, value) => max > value ? max : value);
  }
  
  int _calculateDateInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 10;
  }
}