import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/quiz.dart';

class QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final String? selectedOptionId;
  final bool? isCorrect;
  final bool showExplanation;
  final Function(String) onOptionSelected;
  
  const QuestionCard({
    Key? key,
    required this.question,
    this.selectedOptionId,
    this.isCorrect,
    this.showExplanation = false,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 问题类型标识
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getTypeColor()),
              ),
              child: Text(
                _getTypeLabel(),
                style: TextStyle(
                  color: _getTypeColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 问题文本
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 选项列表
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  return _buildOptionItem(option);
                },
              ),
            ),
            
            // 解析区域
            if (showExplanation && isCorrect != null)
              _buildExplanationSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionItem(QuizOption option) {
    // 判断选项状态
    bool isSelected = option.id == selectedOptionId;
    bool isCorrect = option.id == question.correctOptionId;
    bool showCorrectness = selectedOptionId != null;
    
    // 确定选项颜色
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    
    if (showCorrectness) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      } else {
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade800;
      }
    } else {
      backgroundColor = isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade50;
      borderColor = isSelected ? AppTheme.primaryColor : Colors.grey.shade300;
      textColor = isSelected ? AppTheme.primaryColor : Colors.black;
    }
    
    return GestureDetector(
      onTap: selectedOptionId == null
          ? () => onOptionSelected(option.id)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected || isCorrect && showCorrectness
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (showCorrectness)
              Icon(
                isCorrect
                    ? Icons.check_circle
                    : isSelected
                        ? Icons.cancel
                        : Icons.circle_outlined,
                color: isCorrect
                    ? Colors.green
                    : isSelected
                        ? Colors.red
                        : Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExplanationSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect! ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect! ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect! ? Icons.check_circle : Icons.info,
                color: isCorrect! ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect! ? '回答正确!' : '解析',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect! ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation ?? '该问题没有提供解析。',
            style: TextStyle(
              color: isCorrect! ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getTypeLabel() {
    switch (question.type) {
      case QuestionType.wordToMeaning:
        return '单词→释义';
      case QuestionType.meaningToWord:
        return '释义→单词';
      case QuestionType.sentenceCompletion:
        return '句子填空';
      case QuestionType.challenge:
        return '挑战题';
      default:
        return '未知类型';
    }
  }
  
  Color _getTypeColor() {
    switch (question.type) {
      case QuestionType.wordToMeaning:
        return Colors.green;
      case QuestionType.meaningToWord:
        return Colors.blue;
      case QuestionType.sentenceCompletion:
        return Colors.orange;
      case QuestionType.challenge:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}