import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/level.dart';
import '../../../../data/models/user_progress.dart';
import '../../../../data/mocks/mock_data.dart';

class LevelListPage extends StatefulWidget {
  final String examType;
  
  const LevelListPage({
    Key? key,
    required this.examType,
  }) : super(key: key);

  @override
  State<LevelListPage> createState() => _LevelListPageState();
}

class _LevelListPageState extends State<LevelListPage> {
  final MockData _mockData = MockData();
  bool _isGridView = true;
  
  @override
  Widget build(BuildContext context) {
    // 获取模拟数据
    final user = _mockData.getMockUser();
    final levels = _mockData.getMockLevels()
        .where((level) => level.examType == widget.examType)
        .toList();
    final progresses = _mockData.getMockUserProgress(user.id);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examType} 词汇学习'),
        actions: [
          // 切换视图按钮
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 导航到设置页面
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 提醒区域
          _buildRemindersSection(progresses),
          
          // 主要内容区域
          Expanded(
            child: _isGridView
                ? _buildGridView(levels, progresses)
                : _buildListView(levels, progresses),
          ),
        ],
      ),
      // 修改底部导航栏的onTap处理
    bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: '学习',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.refresh),
                label: '复习',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: '统计',
            ),
        ],
        onTap: (index) {
            if (index == 1) {
            // 导航到复习页面
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReviewPlanPage(),
                    ),
                );
            } else if (index == 2) {
            // TODO: 导航到统计页面
            }
        },
    ),
  }
  
  Widget _buildRemindersSection(List<UserProgress> progresses) {
    // 获取需要复习的关卡
    final reviewDueProgresses = progresses.where((progress) {
      return progress.reviews.any((review) => 
        review.completedAt == null && 
        review.scheduledFor.isBefore(DateTime.now()));
    }).toList();
    
    if (reviewDueProgresses.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                '待复习关卡',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('你有 ${reviewDueProgresses.length} 个关卡需要复习'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: 导航到复习页面
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
            ),
            child: const Text('立即复习'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridView(List<Level> levels, List<UserProgress> progresses) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        // 获取关卡的进度
        final progress = progresses.firstWhere(
          (p) => p.levelId == level.id,
          orElse: () => UserProgress(
            id: '',
            userId: '',
            levelId: level.id,
            status: 'NOT_STARTED',
            progress: 0,
            testResults: [],
            wordStatus: [],
            reviews: [],
          ),
        );
        
        return _buildLevelCard(level, progress);
      },
    );
  }
  
  Widget _buildListView(List<Level> levels, List<UserProgress> progresses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        // 获取关卡的进度
        final progress = progresses.firstWhere(
          (p) => p.levelId == level.id,
          orElse: () => UserProgress(
            id: '',
            userId: '',
            levelId: level.id,
            status: 'NOT_STARTED',
            progress: 0,
            testResults: [],
            wordStatus: [],
            reviews: [],
          ),
        );
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${level.sequence}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              level.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${level.wordIds.length} 个单词 • ${level.estimatedTime} 分钟'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(progress.status),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(progress.status),
                  style: TextStyle(
                    color: _getProgressColor(progress.status),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              _onLevelSelected(level, progress);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildLevelCard(Level level, UserProgress progress) {
    bool isUnlocked = level.sequence == 1 || 
        (progress.status != 'NOT_STARTED' || 
         // 前一关卡已完成
         _isPreviousLevelCompleted(level));
    
    return GestureDetector(
      onTap: isUnlocked ? () => _onLevelSelected(level, progress) : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 关卡图像区域
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: isUnlocked
                        ? const Icon(Icons.image, size: 40, color: Colors.grey)
                        : const Icon(Icons.lock, size: 40, color: Colors.grey),
                  ),
                ),
                // 关卡信息区域
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${level.wordIds.length} 个单词 • ${level.estimatedTime} 分钟',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: isUnlocked ? progress.progress / 100 : 0,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(progress.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUnlocked 
                              ? _getStatusText(progress.status)
                              : '未解锁',
                          style: TextStyle(
                            color: isUnlocked 
                                ? _getProgressColor(progress.status)
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 关卡序号
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${level.sequence}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _isPreviousLevelCompleted(Level level) {
    // 在实际应用中，需要检查前一关卡的完成状态
    // 这里简化为直接返回true
    return true;
  }
  
  Color _getProgressColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppTheme.secondaryColor;
      case 'TESTING':
      case 'LEARNING':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'COMPLETED':
        return '已完成';
      case 'TESTING':
        return '测验中';
      case 'LEARNING':
        return '学习中';
      default:
        return '未开始';
    }
  }
  
  void _onLevelSelected(Level level, UserProgress progress) {
      // 根据关卡状态决定导航行为
    if (progress.status == 'NOT_STARTED' || progress.status == 'LEARNING') {
        // 导航到词根学习页面
        Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RootLearningPage(
            levelId: level.id,
            ),
        ),
        );
    } else if (progress.status == 'TESTING') {
        // 导航到测验页面
        // TODO: 导航到测验页面
        print('导航到测验页面: ${level.title}');
    } else {
        // 导航到复习页面
        // TODO: 导航到复习页面
        print('导航到复习页面: ${level.title}');
    }
    }
}