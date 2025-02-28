class Level {
  final String id;
  final String title;
  final String rootId;
  final String examType;
  final int sequence;
  final List<String> wordIds;
  final List<String> challengeWordIds;
  final String imageUrl;
  final String description;
  final int estimatedTime;
  
  Level({
    required this.id,
    required this.title,
    required this.rootId,
    required this.examType,
    required this.sequence,
    required this.wordIds,
    required this.challengeWordIds,
    required this.imageUrl,
    required this.description,
    required this.estimatedTime,
  });
  
  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['_id'],
      title: json['title'],
      rootId: json['rootId'],
      examType: json['examType'],
      sequence: json['sequence'],
      wordIds: List<String>.from(json['wordIds']),
      challengeWordIds: List<String>.from(json['challengeWordIds']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      estimatedTime: json['estimatedTime'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'rootId': rootId,
      'examType': examType,
      'sequence': sequence,
      'wordIds': wordIds,
      'challengeWordIds': challengeWordIds,
      'imageUrl': imageUrl,
      'description': description,
      'estimatedTime': estimatedTime,
    };
  }
}