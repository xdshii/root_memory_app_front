import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/services/audio_service.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/review.dart';
import '../blocs/review_bloc.dart';
import '../widgets/review_result_card.dart';

class UnitReviewPage extends StatefulWidget {
  const UnitReviewPage({Key? key}) : super(key: key);

  @override
  State<UnitReviewPage> createState() => _UnitReviewPageState();
}

class _UnitReviewPageState extends State<UnitReviewPage> {
  final AudioService _audioService = AudioService();
  bool _isDefinitionVisible = false;
  
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关卡复习'),
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewCompleted) {
            // 复习完成，显示结果
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('复习完成'),
                content: ReviewResultCard(
                  score: state.score,
                  reviewPlan: state.reviewPlan,
                  nextReviewDate: state.nextReviewDate,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 返回复习计划页面
                      Navigator.pop(context); // 关闭对话框
                      Navigator.pop(context); // 返回复习计划页面
                      
                      // 刷新复习计划列表
                      context.read<ReviewBloc>().add(
                        const ReviewPlansRequested(userId: 'current_user'),
                      );
                    },
                    child: const Text('返回'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UnitReviewInProgress) {
            return _buildReviewInProgress(context, state);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildReviewInProgress(
    BuildContext context, 
    UnitReviewInProgress state,
  ) {
    final word = state.currentWord;
    
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
                    '进度: ${state.currentWordIndex + 1}/${state.words.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '正确: ${state.correctCount}',
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (state.currentWordIndex + 1) / state.words.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // 单词卡片
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDefinitionVisible = !_isDefinitionVisible;
                });
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // 单词图像
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: word.imageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: word.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(Icons.image, size: 80, color: Colors.grey),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                                ),
                        ),
                      ),
                    ),
                    
                    // 单词信息
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // 单词和发音
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        word.text,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        word.phonetic,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, size: 30),
                                  onPressed: () {
                                    _audioService.playAudio(word.audioUrl);
                                  },
                                  tooltip: '播放发音',
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 定义（点击时显示）
                            if (_isDefinitionVisible)
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...word.definitions.map((definition) => 
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, 
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  definition.pos,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                definition.meaning,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (definition.examples.isNotEmpty)
                                                Text(
                                                  definition.examples.first,
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.touch_app,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '点击查看定义',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // 记忆评估按钮
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMemoryButton(
                context,
                difficulty: MemoryDifficulty.hard,
                label: '困难',
                color: Colors.red,
                wordId: word.id,
              ),
              _buildMemoryButton(
                context,
                difficulty: MemoryDifficulty.medium,
                label: '一般',
                color: Colors.orange,
                wordId: word.id,
              ),
              _buildMemoryButton(
                context,
                difficulty: MemoryDifficulty.easy,
                label: '简单',
                color: Colors.green,
                wordId: word.id,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMemoryButton(
    BuildContext context, {
    required MemoryDifficulty difficulty,
    required String label,
    required Color color,
    required String wordId,
  }) {
    return ElevatedButton(
      onPressed: () {
        // 记录记忆难度并前进到下一个单词
        context.read<ReviewBloc>().add(WordMemoryRated(
          wordId: wordId,
          difficulty: difficulty,
        ));
        
        // 重置定义可见性状态
        setState(() {
          _isDefinitionVisible = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(80, 48),
      ),
      child: Text(label),
    );
  }
}