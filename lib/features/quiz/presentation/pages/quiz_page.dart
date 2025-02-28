import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/quiz.dart';
import '../../../../data/models/word.dart';
import '../../../../data/mocks/mock_data.dart';
import '../blocs/quiz_bloc.dart';
import '../widgets/question_card.dart';
import '../widgets/quiz_result_card.dart';

class QuizPage extends StatefulWidget {
  final String levelId;
  
  const QuizPage({
    Key? key,
    required this.levelId,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final MockData _mockData = MockData();
  late QuizBloc _quizBloc;
  
  @override
  void initState() {
    super.initState();
    _quizBloc = QuizBloc();
    _initializeQuiz();
  }
  
  @override
  void dispose() {
    _quizBloc.close();
    super.dispose();
  }
  
  void _initializeQuiz() {
    // 获取关卡测验
    final quiz = _mockData.getMockQuizForLevel(widget.levelId);
    
    // 开始测验
    _quizBloc.add(QuizStarted(quiz: quiz));
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _quizBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('词根测验'),
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            // 可以处理状态变化的通知，例如显示snackbar等
          },
          builder: (context, state) {
            if (state is QuizLoading || state is QuizInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is QuizInProgress) {
              return _buildQuizInProgress(context, state);
            } else if (state is QuizFinished) {
              return _buildQuizFinished(context, state);
            } else {
              return const Center(
                child: Text('未知状态'),
              );
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildQuizInProgress(BuildContext context, QuizInProgress state) {
    final currentQuestion = state.currentQuestion;
    
    return Column(
      children: [
        // 顶部信息栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 级别和进度信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '测验级别: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildLevelIndicator(state.currentLevel),
                    ],
                  ),
                  Text(
                    '进度: ${state.currentQuestionIndex + 1}/${state.quiz.questions.length}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 进度条
              LinearProgressIndicator(
                value: (state.currentQuestionIndex + 1) / state.quiz.questions.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getLevelColor(state.currentLevel),
                ),
              ),
            ],
          ),
        ),
        
        // 问题卡片
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QuestionCard(
              question: currentQuestion,
              selectedOptionId: state.selectedOptionId,
              isCorrect: state.isCorrect,
              showExplanation: state.showExplanation,
              onOptionSelected: (optionId) {
                context.read<QuizBloc>().add(AnswerSubmitted(optionId: optionId));
              },
            ),
          ),
        ),
        
        // 底部操作栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: state.showExplanation
                    ? () {
                        context.read<QuizBloc>().add(NextQuestionRequested());
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.showExplanation
                      ? AppTheme.primaryColor
                      : Colors.grey[300],
                  minimumSize: const Size(120, 48),
                ),
                child: Text(state.isLastQuestion ? '完成测验' : '下一题'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuizFinished(BuildContext context, QuizFinished state) {
    // 获取测验结果
    final result = state.result;
    
    // 获取关卡信息
    final level = _mockData.getMockLevels().firstWhere(
      (l) => l.id == result.levelId,
      orElse: () => throw Exception('Level not found'),
    );
    
    // 获取词根信息
    final root = _mockData.getMockRoots().firstWhere(
      (r) => r.id == level.rootId,
      orElse: () => throw Exception('Root not found'),
    );
    
    // 获取薄弱单词
    final weakWords = state.weakWordIds.isNotEmpty
        ? _mockData.getMockWords().where(
            (w) => state.weakWordIds.contains(w.id),
          ).toList()
        : <Word>[];
    
    return QuizResultCard(
      result: result,
      level: level,
      root: root,
      resultsByLevel: state.resultsByLevel,
      weakWords: weakWords,
      onRetest: () {
        // 重新测验
        _initializeQuiz();
      },
      onContinue: () {
        // 继续学习 (返回到关卡列表)
        Navigator.pop(context);
      },
    );
  }
  
  Widget _buildLevelIndicator(int level) {
    final color = _getLevelColor(level);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getLevelIcon(level),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _getLevelLabel(level),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getLevelLabel(int level) {
    switch (level) {
      case 1:
        return '单词-释义';
      case 2:
        return '释义-单词';
      case 3:
        return '句子填空';
      case 4:
        return '挑战题';
      default:
        return '未知';
    }
  }
  
  IconData _getLevelIcon(int level) {
    switch (level) {
      case 1:
        return Icons.check_circle_outline;
      case 2:
        return Icons.extension;
      case 3:
        return Icons.format_quote;
      case 4:
        return Icons.lightbulb_outline;
      default:
        return Icons.help_outline;
    }
  }
  
  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}