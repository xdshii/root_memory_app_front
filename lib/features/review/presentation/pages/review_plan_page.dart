import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/review.dart';
import '../../../../data/mocks/mock_data.dart';
import '../blocs/review_bloc.dart';
import 'unit_review_page.dart';
import 'flashcard_review_page.dart';

class ReviewPlanPage extends StatefulWidget {
  const ReviewPlanPage({Key? key}) : super(key: key);

  @override
  State<ReviewPlanPage> createState() => _ReviewPlanPageState();
}

class _ReviewPlanPageState extends State<ReviewPlanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReviewBloc _reviewBloc;
  final MockData _mockData = MockData();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reviewBloc = ReviewBloc();
    
    // 获取当前用户的复习计划
    _reviewBloc.add(const ReviewPlansRequested(userId: 'current_user'));
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _reviewBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reviewBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('复习计划'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '日历视图'),
              Tab(text: '列表视图'),
            ],
          ),
        ),
        body: BlocConsumer<ReviewBloc, ReviewState>(
          listener: (context, state) {
            // 监听状态变化，可以处理导航或通知
          },
          builder: (context, state) {
            if (state is ReviewPlansLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ReviewPlansLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildCalendarView(context, state),
                  _buildListView(context, state),
                ],
              );
            } else {
              return const Center(
                child: Text('无复习计划数据'),
              );
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildCalendarView(BuildContext context, ReviewPlansLoaded state) {
    // 当前日期
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    
    // 所有复习计划
    final allReviewPlans = [
      ...state.overdueReviewPlans,
      ...state.todayReviewPlans,
      ...state.upcomingReviewPlans,
      ...state.completedReviewPlans,
    ];
    
    // 建立日期到复习计划的映射
    final Map<DateTime, List<ReviewPlan>> reviewsByDate = {};
    
    for (var plan in allReviewPlans) {
      final date = DateTime(
        plan.scheduledFor.year,
        plan.scheduledFor.month,
        plan.scheduledFor.day,
      );
      
      if (!reviewsByDate.containsKey(date)) {
        reviewsByDate[date] = [];
      }
      
      reviewsByDate[date]!.add(plan);
    }
    
    return Column(
      children: [
        // 月份选择器
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  // 上一个月
                },
              ),
              Text(
                DateFormat('yyyy年MM月').format(currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  // 下一个月
                },
              ),
            ],
          ),
        ),
        
        // 日历网格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _getDaysInMonth(currentMonth) + _getFirstDayOfMonth(currentMonth),
            itemBuilder: (context, index) {
              // 填充月初空白
              if (index < _getFirstDayOfMonth(currentMonth)) {
                return Container();
              }
              
              final day = index - _getFirstDayOfMonth(currentMonth) + 1;
              final date = DateTime(currentMonth.year, currentMonth.month, day);
              
              // 检查这一天是否有复习计划
              final hasReviews = reviewsByDate.containsKey(date);
              final isToday = date.year == now.year && 
                             date.month == now.month && 
                             date.day == now.day;
              
              return GestureDetector(
                onTap: hasReviews ? () {
                  _showReviewsForDate(context, date, reviewsByDate[date]!);
                } : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primaryColor.withOpacity(0.1) : null,
                    border: Border.all(
                      color: isToday ? AppTheme.primaryColor : Colors.grey.shade300,
                      width: isToday ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? AppTheme.primaryColor : null,
                        ),
                      ),
                      if (hasReviews)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getReviewStatusColor(reviewsByDate[date]!),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // 今日复习摘要
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '今日复习',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (state.overdueReviewPlans.isEmpty && 
                  state.todayReviewPlans.isEmpty &&
                  state.dueFlashcardReviews.isEmpty)
                const Text('今日没有需要复习的内容'),
              if (state.overdueReviewPlans.isNotEmpty)
                _buildReviewPlanCard(
                  title: '已过期复习',
                  count: state.overdueReviewPlans.length,
                  color: Colors.red,
                  onPressed: () {
                    _startReview(context, state.overdueReviewPlans.first);
                  },
                ),
              if (state.todayReviewPlans.isNotEmpty)
                _buildReviewPlanCard(
                  title: '今日复习',
                  count: state.todayReviewPlans.length,
                  color: AppTheme.primaryColor,
                  onPressed: () {
                    _startReview(context, state.todayReviewPlans.first);
                  },
                ),
              if (state.dueFlashcardReviews.isNotEmpty)
                _buildReviewPlanCard(
                  title: '闪卡复习',
                  count: state.dueFlashcardReviews.length,
                  color: Colors.purple,
                  onPressed: () {
                    _startFlashcardReview(context, state.dueFlashcardReviews);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildListView(BuildContext context, ReviewPlansLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 过期复习
        if (state.overdueReviewPlans.isNotEmpty) ...[
          _buildSectionHeader(
            title: '已过期复习', 
            icon: Icons.warning, 
            color: Colors.red,
          ),
          ...state.overdueReviewPlans.map((plan) => 
            _buildReviewPlanListItem(context, plan)
          ),
          const SizedBox(height: 16),
        ],
        
        // 今日复习
        if (state.todayReviewPlans.isNotEmpty) ...[
          _buildSectionHeader(
            title: '今日复习', 
            icon: Icons.today, 
            color: AppTheme.primaryColor,
          ),
          ...state.todayReviewPlans.map((plan) => 
            _buildReviewPlanListItem(context, plan)
          ),
          const SizedBox(height: 16),
        ],
        
        // 闪卡复习
        if (state.dueFlashcardReviews.isNotEmpty) ...[
          _buildSectionHeader(
            title: '闪卡复习', 
            icon: Icons.flash_on, 
            color: Colors.purple,
          ),
          _buildFlashcardReviewItem(
            context, 
            state.dueFlashcardReviews,
          ),
          const SizedBox(height: 16),
        ],
        
        // 即将到期
        if (state.upcomingReviewPlans.isNotEmpty) ...[
          _buildSectionHeader(
            title: '即将到期', 
            icon: Icons.access_time, 
            color: Colors.orange,
          ),
          ...state.upcomingReviewPlans.map((plan) => 
            _buildReviewPlanListItem(context, plan)
          ),
          const SizedBox(height: 16),
        ],
        
        // 已完成
        if (state.completedReviewPlans.isNotEmpty) ...[
          _buildSectionHeader(
            title: '已完成复习', 
            icon: Icons.check_circle, 
            color: Colors.green,
          ),
          ...state.completedReviewPlans.map((plan) => 
            _buildReviewPlanListItem(context, plan, isEnabled: false)
          ),
        ],
      ],
    );
  }
  
  Widget _buildSectionHeader({
    required String title, 
    required IconData icon, 
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewPlanListItem(
    BuildContext context, 
    ReviewPlan plan, 
    {bool isEnabled = true}
  ) {
    // 获取关卡信息
    final level = _mockData.getMockLevels().firstWhere(
      (l) => l.id == plan.levelId,
      orElse: () => throw Exception('Level not found'),
    );
    
    final isFlashcard = plan.type == ReviewType.flashcard;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getReviewTypeColor(plan.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFlashcard ? Icons.flash_on : Icons.book,
            color: _getReviewTypeColor(plan.type),
          ),
        ),
        title: Text(
          isFlashcard ? '闪卡复习' : level.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plan.wordIds.length}个单词 • ${_getReviewDuration(plan)}分钟',
            ),
            Text(
              _getReviewTimeText(plan),
              style: TextStyle(
                color: _getReviewStatusColor([plan]),
                fontSize: 12,
              ),
            ),
            if (plan.status == ReviewStatus.completed && plan.score != null)
              Text(
                '得分: ${plan.score}%',
                style: TextStyle(
                  color: _getScoreColor(plan.score!),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: isEnabled
            ? ElevatedButton(
                onPressed: () {
                  _startReview(context, plan);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getReviewStatusColor([plan]),
                  minimumSize: const Size(80, 36),
                ),
                child: Text(
                  plan.status == ReviewStatus.overdue ? '立即复习' : '开始',
                ),
              )
            : null,
        enabled: isEnabled,
      ),
    );
  }
  
  Widget _buildFlashcardReviewItem(
    BuildContext context, 
    List<FlashcardReview> flashcardReviews,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.flash_on,
            color: Colors.purple,
          ),
        ),
        title: const Text(
          '难点单词闪卡复习',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${flashcardReviews.length}个单词 • ${flashcardReviews.length}分钟',
            ),
            const Text(
              '今日到期',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _startFlashcardReview(context, flashcardReviews);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('开始'),
        ),
      ),
    );
  }
  
  Widget _buildReviewPlanCard({
    required String title,
    required int count,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForTitle(title),
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$count个项目需要复习',
                    style: TextStyle(
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
              ),
              child: const Text('开始'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showReviewsForDate(
    BuildContext context, 
    DateTime date, 
    List<ReviewPlan> reviews,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('yyyy年MM月dd日').format(date),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...reviews.map((plan) => _buildReviewPlanListItem(context, plan)),
          ],
        ),
      ),
    );
  }
  
  void _startReview(BuildContext context, ReviewPlan plan) {
    // 开始复习
    context.read<ReviewBloc>().add(ReviewSelected(reviewPlan: plan));
    
    // 导航到复习页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UnitReviewPage(),
      ),
    );
  }
  
  void _startFlashcardReview(
    BuildContext context, 
    List<FlashcardReview> flashcardReviews,
  ) {
    // 开始闪卡复习
    context.read<ReviewBloc>().add(FlashcardReviewSelected(
      flashcardReviews: flashcardReviews,
    ));
    
    // 导航到闪卡复习页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FlashcardReviewPage(),
      ),
    );
  }
  
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
  
  int _getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }
  
  Color _getReviewStatusColor(List<ReviewPlan> plans) {
    if (plans.any((plan) => plan.status == ReviewStatus.overdue)) {
      return Colors.red;
    } else if (plans.any((plan) => 
      plan.status == ReviewStatus.scheduled && 
      plan.scheduledFor.isBefore(DateTime.now())
    )) {
      return Colors.red;
    } else if (plans.any((plan) => 
      plan.status == ReviewStatus.scheduled && 
      plan.scheduledFor.day == DateTime.now().day
    )) {
      return AppTheme.primaryColor;
    } else if (plans.any((plan) => plan.status == ReviewStatus.completed)) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }
  
  Color _getReviewTypeColor(ReviewType type) {
    switch (type) {
      case ReviewType.unit:
        return AppTheme.primaryColor;
      case ReviewType.flashcard:
        return Colors.purple;
    }
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
  
  String _getReviewTimeText(ReviewPlan plan) {
    if (plan.status == ReviewStatus.completed) {
      return '已完成';
    } else if (plan.status == ReviewStatus.overdue) {
      return '已过期';
    } else {
      final now = DateTime.now();
      final scheduledDate = plan.scheduledFor;
      
      if (scheduledDate.year == now.year && 
          scheduledDate.month == now.month && 
          scheduledDate.day == now.day) {
        return '今日 ${DateFormat('HH:mm').format(scheduledDate)}';
      } else {
        return DateFormat('MM-dd HH:mm').format(scheduledDate);
      }
    }
  }
  
  int _getReviewDuration(ReviewPlan plan) {
    // 简单估算复习时间，每个单词约1分钟
    return plan.wordIds.length;
  }
  
  IconData _getIconForTitle(String title) {
    if (title.contains('过期')) {
      return Icons.warning;
    } else if (title.contains('今日')) {
      return Icons.today;
    } else if (title.contains('闪卡')) {
      return Icons.flash_on;
    } else {
      return Icons.book;
    }
  }
}