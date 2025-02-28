import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/review.dart';

class ReviewResultCard extends StatelessWidget {
  final int score;
  final ReviewPlan reviewPlan;
  final DateTime nextReviewDate;
  
  const ReviewResultCard({
    Key? key,
    required this.score,
    required this.reviewPlan,
    required this.nextReviewDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 成绩环
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(score),
                      ),
                    ),
                    Text(
                      _getScoreDescription(score),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getScoreColor(score),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 恭喜信息
          Text(
            _getCompletionMessage(score),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // 下次复习时间
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  '下次复习安排',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy年MM月dd日').format(nextReviewDate),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getTimeUntilNextReview(nextReviewDate),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 记忆规律提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '记忆小贴士',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '根据艾宾浩斯遗忘曲线，科学安排的间隔复习可以显著提高记忆效果。持续坚持复习计划，你的词汇量将稳步提升！',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 90) {
      return Colors.green;
    } else if (score >= 70) {
      return Colors.blue;
    } else if (score >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  String _getScoreDescription(int score) {
    if (score >= 90) {
      return '优秀';
    } else if (score >= 70) {
      return '良好';
    } else if (score >= 60) {
      return '及格';
    } else {
      return '需加强';
    }
  }
  
  String _getCompletionMessage(int score) {
    if (score >= 90) {
      return '太棒了！你的记忆力非常出色！';
    } else if (score >= 70) {
      return '不错！大部分单词你都已掌握！';
    } else if (score >= 60) {
      return '基本掌握，继续努力！';
    } else {
      return '这些单词需要更多练习，加油！';
    }
  }
  
  String _getTimeUntilNextReview(DateTime nextReviewDate) {
    final now = DateTime.now();
    final difference = nextReviewDate.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天后';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时后';
    } else {
      return '即将到来';
    }
  }
}