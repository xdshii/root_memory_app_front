import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../data/models/review.dart';

class VocabularyStatusPie extends StatelessWidget {
  final Map<MemoryDifficulty, int> wordCountByDifficulty;
  
  const VocabularyStatusPie({
    Key? key,
    required this.wordCountByDifficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalWords = wordCountByDifficulty.values
        .fold(0, (sum, count) => sum + count);
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _createSections(totalWords),
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // 响应触摸事件，可显示详细信息
          },
        ),
      ),
    );
  }
  
  List<PieChartSectionData> _createSections(int totalWords) {
    final List<PieChartSectionData> sections = [];
    
    // 难单词（困难）
    final hardCount = wordCountByDifficulty[MemoryDifficulty.hard] ?? 0;
    if (hardCount > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: hardCount.toDouble(),
          title: '${((hardCount / totalWords) * 100).toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    // 中等难度单词
    final mediumCount = wordCountByDifficulty[MemoryDifficulty.medium] ?? 0;
    if (mediumCount > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.orange,
          value: mediumCount.toDouble(),
          title: '${((mediumCount / totalWords) * 100).toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    // 简单单词（已掌握）
    final easyCount = wordCountByDifficulty[MemoryDifficulty.easy] ?? 0;
    if (easyCount > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.green,
          value: easyCount.toDouble(),
          title: '${((easyCount / totalWords) * 100).toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return sections;
  }
}