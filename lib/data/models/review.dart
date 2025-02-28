import 'dart:convert';

enum ReviewType {
  unit, // 关卡整体复习
  flashcard, // 单词闪卡复习
}

enum ReviewStatus {
  scheduled, // 已安排
  overdue, // 已过期
  completed, // 已完成
  cancelled, // 已取消
}

enum MemoryDifficulty {
  hard, // 困难 (1天后复习)
  medium, // 一般 (3天后复习)
  easy, // 简单 (7天后复习)
}

class ReviewPlan {
  final String id;
  final String userId;
  final String levelId;
  final ReviewType type;
  final DateTime scheduledFor;
  final DateTime? completedAt;
  final ReviewStatus status;
  final int? score;
  final List<String> wordIds; // 需要复习的单词IDs
  
  ReviewPlan({
    required this.id,
    required this.userId,
    required this.levelId,
    required this.type,
    required this.scheduledFor,
    this.completedAt,
    required this.status,
    this.score,
    required this.wordIds,
  });
  
  factory ReviewPlan.fromJson(Map<String, dynamic> json) {
    return ReviewPlan(
      id: json['id'],
      userId: json['userId'],
      levelId: json['levelId'],
      type: ReviewType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      scheduledFor: DateTime.parse(json['scheduledFor']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      status: ReviewStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      score: json['score'],
      wordIds: List<String>.from(json['wordIds']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'levelId': levelId,
      'type': type.toString().split('.').last,
      'scheduledFor': scheduledFor.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'score': score,
      'wordIds': wordIds,
    };
  }
  
  ReviewPlan copyWith({
    String? id,
    String? userId,
    String? levelId,
    ReviewType? type,
    DateTime? scheduledFor,
    DateTime? completedAt,
    ReviewStatus? status,
    int? score,
    List<String>? wordIds,
  }) {
    return ReviewPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      levelId: levelId ?? this.levelId,
      type: type ?? this.type,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      score: score ?? this.score,
      wordIds: wordIds ?? this.wordIds,
    );
  }
}

class FlashcardReview {
  final String wordId;
  final MemoryDifficulty difficulty;
  final DateTime lastReviewed;
  final DateTime nextReview;
  
  FlashcardReview({
    required this.wordId,
    required this.difficulty,
    required this.lastReviewed,
    required this.nextReview,
  });
  
  factory FlashcardReview.fromJson(Map<String, dynamic> json) {
    return FlashcardReview(
      wordId: json['wordId'],
      difficulty: MemoryDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      lastReviewed: DateTime.parse(json['lastReviewed']),
      nextReview: DateTime.parse(json['nextReview']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'difficulty': difficulty.toString().split('.').last,
      'lastReviewed': lastReviewed.toIso8601String(),
      'nextReview': nextReview.toIso8601String(),
    };
  }
  
  FlashcardReview copyWith({
    String? wordId,
    MemoryDifficulty? difficulty,
    DateTime? lastReviewed,
    DateTime? nextReview,
  }) {
    return FlashcardReview(
      wordId: wordId ?? this.wordId,
      difficulty: difficulty ?? this.difficulty,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
    );
  }
}