class Word {
  final String id;
  final String text;
  final List<String> rootIds;
  final List<String> prefixes;
  final List<String> suffixes;
  final String phonetic;
  final String audioUrl;
  final String imageUrl;
  final List<String> partOfSpeech;
  final List<WordDefinition> definitions;
  final List<String> examTags;
  final int difficulty;
  
  Word({
    required this.id,
    required this.text,
    required this.rootIds,
    required this.prefixes,
    required this.suffixes,
    required this.phonetic,
    required this.audioUrl,
    required this.imageUrl,
    required this.partOfSpeech,
    required this.definitions,
    required this.examTags,
    required this.difficulty,
  });
  
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['_id'],
      text: json['text'],
      rootIds: List<String>.from(json['rootIds']),
      prefixes: List<String>.from(json['prefixes']),
      suffixes: List<String>.from(json['suffixes']),
      phonetic: json['phonetic'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      partOfSpeech: List<String>.from(json['partOfSpeech']),
      definitions: (json['definitions'] as List)
          .map((def) => WordDefinition.fromJson(def))
          .toList(),
      examTags: List<String>.from(json['examTags']),
      difficulty: json['difficulty'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'rootIds': rootIds,
      'prefixes': prefixes,
      'suffixes': suffixes,
      'phonetic': phonetic,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'partOfSpeech': partOfSpeech,
      'definitions': definitions.map((def) => def.toJson()).toList(),
      'examTags': examTags,
      'difficulty': difficulty,
    };
  }
}

class WordDefinition {
  final String pos;
  final String meaning;
  final List<String> examples;
  
  WordDefinition({
    required this.pos,
    required this.meaning,
    required this.examples,
  });
  
  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    return WordDefinition(
      pos: json['pos'],
      meaning: json['meaning'],
      examples: List<String>.from(json['examples']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'pos': pos,
      'meaning': meaning,
      'examples': examples,
    };
  }
}