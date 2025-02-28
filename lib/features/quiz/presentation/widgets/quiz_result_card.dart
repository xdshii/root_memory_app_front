import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/level.dart';
import '../../../../data/models/quiz_result.dart';
import '../../../../data/models/root.dart';
import '../../../../data/models/word.dart';

class QuizResultCard extends StatelessWidget {
  final QuizResult result;
  final Level level;
  final Root root;
  final Map<int, List<QuestionResult>> resultsByLevel;
  final List<Word> weakWords;
  final VoidCallback onRetest;
  final VoidCallback onContinue;
  
  const QuizResultCard({
    Key? key,
    required this.result,
    required this.level,
    required this.root,
    required this.resultsByLevel,
    required this.weakWords,
    required this.onRetest,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 结果标题
          Text(
            result.passed ? '恭喜！测验通过！' : '测验未通过',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: result.passed ? AppTheme.secondaryColor : AppTheme.accentColor,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 成绩环形图表
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: result.score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(result.score),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${result.score}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(result.score),
                      ),
                    ),
                    Text(
                      '${result.correctCount}/${result.totalCount}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 关卡信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '词根: ${root.text} - ${root.meaning}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 成绩分析
          const Text(
            '成绩分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildLevelResults(),
          
          const SizedBox(height: 24),
          
          // 需要加强的单词
          if (weakWords.isNotEmpty) ...[
            const Text(
              '需要加强的单词',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildWeakWordsList(),
            const SizedBox(height: 24),
          ],
          
          // 复习安排
          const Text(
            '复习安排',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '首次复习',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '明天 (${_getFormattedDate(DateTime.now().add(const Duration(days: 1)))})',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetest,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('重新测验'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('继续学习'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelResults() {
    final levels = resultsByLevel.keys.toList()..sort();
    
    return Column(
      children: levels.map((level) {
        final levelResults = resultsByLevel[level]!;
        final correctCount = levelResults.where((r) => r.correct).length;
        final totalCount = levelResults.length;
        final percentage = totalCount > 0 
            ? (correctCount / totalCount * 100).round() 
            : 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getLevelLabel(level),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$correctCount/$totalCount (${percentage}%)',
                style: TextStyle(
                  color: _getScoreColor(percentage.toDouble()),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildWeakWordsList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weakWords.map((word) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(
                Icons.warning,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                word.text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '- ${word.definitions.first.meaning}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
  
  String _getLevelLabel(int level) {
    switch (level) {
      case 1:
        return '单词-释义题';
      case 2:
        return '释义-单词题';
      case 3:
        return '句子填空题';
      case 4:
        return '挑战题';
      default:
        return '未知类型';
    }
  }
  
  Color _getScoreColor(double score) {
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
  
  String _getFormattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}