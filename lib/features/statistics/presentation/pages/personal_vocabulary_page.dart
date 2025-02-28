import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/repositories/statistics_repository.dart';
import '../blocs/statistics_bloc.dart';

class PersonalVocabularyPage extends StatefulWidget {
  const PersonalVocabularyPage({Key? key}) : super(key: key);

  @override
  State<PersonalVocabularyPage> createState() => _PersonalVocabularyPageState();
}

class _PersonalVocabularyPageState extends State<PersonalVocabularyPage> {
  String? _selectedStatus;
  String? _selectedRoot;
  final List<String> _statusFilters = ['MASTERED', 'LEARNING', 'DIFFICULT', null];
  final List<String> _statusLabels = ['已掌握', '学习中', '困难', '全部'];
  int _currentPage = 0;
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // 加载初始词汇数据
    _loadVocabularyData();
    
    // 监听滚动以实现分页加载
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _loadVocabularyData() {
    context.read<StatisticsBloc>().add(LoadVocabularyStatus(
      userId: 'current_user',
      status: _selectedStatus,
      rootId: _selectedRoot,
      offset: _currentPage * _pageSize,
      limit: _pageSize,
    ));
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // 滚动到底部，加载更多
      final state = context.read<StatisticsBloc>().state;
      if (state is VocabularyStatusLoaded && state.hasMore) {
        _currentPage++;
        _loadVocabularyData();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatisticsBloc(
        repository: StatisticsRepository(),
      )..add(LoadVocabularyStatus(
          userId: 'current_user',
          offset: 0,
          limit: _pageSize,
        )),
      child: BlocConsumer<StatisticsBloc, StatisticsState>(
        listener: (context, state) {
          // 监听状态变化，处理错误等
        },
        builder: (context, state) {
          return Column(
            children: [
              // 筛选器
              _buildFilterSection(),
              
              // 词汇列表
              Expanded(
                child: state is VocabularyStatusLoaded
                    ? _buildVocabularyList(state)
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '筛选单词',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(
              _statusFilters.length,
              (index) => ChoiceChip(
                label: Text(_statusLabels[index]),
                selected: _selectedStatus == _statusFilters[index],
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? _statusFilters[index] : null;
                    _currentPage = 0;
                  });
                  _loadVocabularyData();
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 可以添加词根筛选器、搜索框等
        ],
      ),
    );
  }
  
  Widget _buildVocabularyList(VocabularyStatusLoaded state) {
    if (state.vocabularyItems.isEmpty) {
      return const Center(
        child: Text('没有符合条件的单词'),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.vocabularyItems.length + 1, // +1 for loading indicator
      itemBuilder: (context, index) {
        if (index == state.vocabularyItems.length) {
          // 底部加载指示器
          return state.hasMore 
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '--- 已加载全部 ${state.totalCount} 个单词 ---',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
        }
        
        final item = state.vocabularyItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Row(
              children: [
                Text(
                  item.word.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(item.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(item.status),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.word.definitions.first.meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '正确率: ${item.correctRate}%',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '复习: ${item.reviewCount}次',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // 显示操作菜单
                _showWordActionMenu(context, item);
              },
            ),
            onTap: () {
              // 查看单词详情
              // TODO: 导航到单词详情页
            },
          ),
        );
      },
    );
  }
  
  void _showWordActionMenu(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('查看详情'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到单词详情页
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('添加到复习'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 添加到复习计划
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('标记为困难词'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 标记为困难词
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('标记为已掌握'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 标记为已掌握
            },
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'MASTERED':
        return Colors.green;
      case 'LEARNING':
        return AppTheme.primaryColor;
      case 'DIFFICULT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'MASTERED':
        return '已掌握';
      case 'LEARNING':
        return '学习中';
      case 'DIFFICULT':
        return '困难';
      default:
        return '未知';
    }
  }
}