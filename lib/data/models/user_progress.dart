class UserProgress {
  final String id;
  final String userId;
  final String levelId;
  final String status; // NOT_STARTED, LEARNING, TESTING, COMPLETED
  final int progress; // 0-100
  final List<TestResult> testResults;
  final List<WordStatus> wordStatus;
  final List<Review> reviews;
  
  UserProgress({
    required this.id,
    required this.userId,
    required this.levelId,
    required this.status,
    required this.progress,
    required this.testResults,
    required this.wordStatus,
    required this.reviews,
  });
  
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['_id'],
      userId: json['userId'],
      levelId: json['levelId'],
      status: json['status'],
      progress: json['progress'],
      testResults: (json['testResults'] as List)
          .map((result) => TestResult.fromJson(result))
          .toList(),
      wordStatus: (json['wordStatus'] as List)
          .map((status) => WordStatus.fromJson(status))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'levelId': levelId,
      'status': status,
      'progress': progress,
      'testResults': testResults.map((result) => result.toJson()).toList(),
      'wordStatus': wordStatus.map((status) => status.toJson()).toList(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
}

class TestResult {
  final DateTime attemptAt;
  final int score;
  final int correctCount;
  final int totalCount;
  
  TestResult({
    required this.attemptAt,
    required this.score,
    required this.correctCount,
    required this.totalCount,
  });
  
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      attemptAt: DateTime.parse(json['attemptAt']),
      score: json['score'],
      correctCount: json['correctCount'],
      totalCount: json['totalCount'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'attemptAt': attemptAt.toIso8601String(),
      'score': score,
      'correctCount': correctCount,
      'totalCount': totalCount,
    };
  }
}

class WordStatus {
  final String wordId;
  final String status; // UNKNOWN, LEARNING, MASTERED
  final int correct;
  final int incorrect;
  final DateTime? lastReviewed;
  
  WordStatus({
    required this.wordId,
    required this.status,
    required this.correct,
    required this.incorrect,
    this.lastReviewed,
  });
  
  factory WordStatus.fromJson(Map<String, dynamic> json) {
    return WordStatus(
      wordId: json['wordId'],
      status: json['status'],
      correct: json['correct'],
      incorrect: json['incorrect'],
      lastReviewed: json['lastReviewed'] != null 
          ? DateTime.parse(json['lastReviewed']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'status': status,
      'correct': correct,
      'incorrect': incorrect,
      'lastReviewed': lastReviewed?.toIso8601String(),
    };
  }
}

class Review {
  final String reviewType; // UNIT, FLASHCARD
  final DateTime scheduledFor;
  final DateTime? completedAt;
  final int? score;
  
  Review({
    required this.reviewType,
    required this.scheduledFor,
    this.completedAt,
    this.score,
  });
  
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewType: json['reviewType'],
      scheduledFor: DateTime.parse(json['scheduledFor']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      score: json['score'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'reviewType': reviewType,
      'scheduledFor': scheduledFor.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'score': score,
    };
  }
}