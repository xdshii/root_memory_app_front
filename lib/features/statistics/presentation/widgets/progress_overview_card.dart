import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/statistics/learning_statistics.dart';

class ProgressOverviewCard extends StatelessWidget {
  final LearningStatistics statistics;
  
  const ProgressOverviewCard({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '学习概览',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  title: '已完成关卡',
                  value: '${statistics.completedLevels}/${statistics.totalLevels}',
                  icon: Icons.check_circle,
                  color: AppTheme.primaryColor,
                ),
                _buildStatItem(
                  context,
                  title: '已掌握词根',
                  value: '${statistics.masteredRoots}/${statistics.totalRoots}',
                  icon: Icons.auto_awesome,
                  color: Colors.orange,
                ),
                _buildStatItem(
                  context,
                  title: '已掌握单词',
                  value: '${statistics.masteredWords}/${statistics.totalWords}',
                  icon: Icons.school,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  title: '平均分数',
                  value: '${statistics.averageScore.toStringAsFixed(1)}',
                  icon: Icons.analytics,
                  color: _getScoreColor(statistics.averageScore),
                  showPercentage: true,
                ),
                _buildStatItem(
                  context,
                  title: '最近7天',
                  value: '${statistics.recentStudyTrend.toStringAsFixed(1)}',
                  icon: Icons.timer,
                  color: AppTheme.primaryColor,
                  suffix: '分钟/天',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool showPercentage = false,
    String? suffix,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (showPercentage)
              Text(
                '%',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            if (suffix != null)
              Text(
                suffix,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 90) {
      return Colors.green;
    } else if (score >= 80) {
      return Colors.blue;
    } else if (score >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}