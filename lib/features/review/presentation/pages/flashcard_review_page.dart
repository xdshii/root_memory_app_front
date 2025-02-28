import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import '../../../../core/services/audio_service.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/review.dart';
import '../blocs/review_bloc.dart';

class FlashcardReviewPage extends StatefulWidget {
  const FlashcardReviewPage({Key? key}) : super(key: key);

  @override
  State<FlashcardReviewPage> createState() => _FlashcardReviewPageState();
}

class _FlashcardReviewPageState extends State<FlashcardReviewPage> {
  final AudioService _audioService = AudioService();
  bool _manuallyFlipped = false;
  
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('闪卡复习'),
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is FlashcardReviewInProgress && !_manuallyFlipped) {
            // 自动翻转检测
            if (!state.isCardFlipped) {
              _manuallyFlipped = false;
            }
          }
        },
        builder: (context, state) {
          if (state is FlashcardReviewInProgress) {
            return _buildFlashcardReview(context, state);
          } else if (state is ReviewCompleting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: Text('开始闪卡复习...'),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildFlashcardReview(
    BuildContext context, 
    FlashcardReviewInProgress state,
  ) {
    return Column(
      children: [
        // 顶部进度条
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '进度: ${state.currentIndex + 1}/${state.words.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.touch_app, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        state.isCardFlipped ? '点击继续' : '点击翻转',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (state.currentIndex + 1) / state.words.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.purple,
                ),
              ),
            ],
          ),
        ),
        
        // 闪卡区域
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                if (state.isCardFlipped) {
                  // 如果已经翻转，则移动到下一个
                  if (state.selectedDifficulty != null) {
                    context.read<ReviewBloc>().add(NextFlashcardRequested());
                  }
                } else {
                  // 翻转卡片
                  _manuallyFlipped = true;
                  context.read<ReviewBloc>().add(NextFlashcardRequested());
                  
                  // 播放发音
                  _audioService.playAudio(state.currentWord.audioUrl);
                }
              },
              child: _buildFlashcard(context, state),
            ),
          ),
        ),
        
        // 记忆评估按钮
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: state.isCardFlipped
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMemoryButton(
                      context,
                      difficulty: MemoryDifficulty.hard,
                      label: '困难',
                      description: '1天后复习',
                      color: Colors.red,
                      isSelected: state.selectedDifficulty == MemoryDifficulty.hard,
                      wordId: state.currentWord.id,
                    ),
                    _buildMemoryButton(
                      context,
                      difficulty: MemoryDifficulty.medium,
                      label: '一般',
                      description: '3天后复习',
                      color: Colors.orange,
                      isSelected: state.selectedDifficulty == MemoryDifficulty.medium,
                      wordId: state.currentWord.id,
                    ),
                    _buildMemoryButton(
                      context,
                      difficulty: MemoryDifficulty.easy,
                      label: '简单',
                      description: '7天后复习',
                      color: Colors.green,
                      isSelected: state.selectedDifficulty == MemoryDifficulty.easy,
                      wordId: state.currentWord.id,
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    '翻转卡片查看答案',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
  
  Widget _buildFlashcard(
    BuildContext context, 
    FlashcardReviewInProgress state,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return _buildFlipAnimation(child, animation);
        },
        child: state.isCardFlipped
            ? _buildCardBack(state)
            : _buildCardFront(state),
      ),
    );
  }
  
  Widget _buildFlipAnimation(Widget child, Animation<double> animation) {
    final rotateAnim = Tween(begin: math.pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: child,
      builder: (context, child) {
        final isBack = rotateAnim.value < math.pi / 2;
        final tilt = ((rotateAnim.value - math.pi / 2).abs() / math.pi) * 0.1;
        return Transform(
          transform: Matrix4.rotationY(rotateAnim.value)
            ..setEntry(3, 0, tilt),
          alignment: Alignment.center,
          child: isBack
              ? child
              : Transform(
                  transform: Matrix4.rotationY(math.pi),
                  alignment: Alignment.center,
                  child: child,
                ),
        );
      },
    );
  }
  
  Widget _buildCardFront(FlashcardReviewInProgress state) {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 单词
          Text(
            state.currentWord.text,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            state.currentWord.phonetic,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Icon(
            Icons.touch_app,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          const Text(
            '点击翻转',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCardBack(FlashcardReviewInProgress state) {
    final word = state.currentWord;
    final definition = word.definitions.first;
    
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 词性和定义
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              definition.pos,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            definition.meaning,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (definition.examples.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      '例句:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      definition.examples.first,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMemoryButton(
    BuildContext context, {
    required MemoryDifficulty difficulty,
    required String label,
    required String description,
    required Color color,
    required bool isSelected,
    required String wordId,
  }) {
    return ElevatedButton(
      onPressed: () {
        // 记录记忆难度
        context.read<ReviewBloc>().add(WordMemoryRated(
          wordId: wordId,
          difficulty: difficulty,
        ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withOpacity(0.2),
        minimumSize: const Size(90, 56),
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white70 : color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}