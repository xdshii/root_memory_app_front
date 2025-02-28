class Root {
  final String id;
  final String text;
  final String origin;
  final String meaning;
  final String memoryAid;
  final String imageUrl;
  final String audioUrl;
  final List<String> examples;
  final int difficulty;
  final Map<String, int> frequency;
  
  Root({
    required this.id,
    required this.text,
    required this.origin,
    required this.meaning,
    required this.memoryAid,
    required this.imageUrl,
    required this.audioUrl,
    required this.examples,
    required this.difficulty,
    required this.frequency,
  });
  
  factory Root.fromJson(Map<String, dynamic> json) {
    return Root(
      id: json['_id'],
      text: json['text'],
      origin: json['origin'],
      meaning: json['meaning'],
      memoryAid: json['memoryAid'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      examples: List<String>.from(json['examples']),
      difficulty: json['difficulty'],
      frequency: Map<String, int>.from(json['frequency']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'origin': origin,
      'meaning': meaning,
      'memoryAid': memoryAid,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'examples': examples,
      'difficulty': difficulty,
      'frequency': frequency,
    };
  }
}