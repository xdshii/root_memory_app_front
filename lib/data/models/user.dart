class User {
  final String id;
  final String username;
  final String email;
  final String examType;
  final String preferredMode;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String deviceToken;
  final UserSettings settings;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.examType,
    this.preferredMode = 'UNIT',
    required this.createdAt,
    required this.lastLogin,
    this.deviceToken = '',
    required this.settings,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      examType: json['examType'],
      preferredMode: json['preferredMode'] ?? 'UNIT',
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      deviceToken: json['deviceToken'] ?? '',
      settings: UserSettings.fromJson(json['settings']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'examType': examType,
      'preferredMode': preferredMode,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'deviceToken': deviceToken,
      'settings': settings.toJson(),
    };
  }
}

class UserSettings {
  final bool reminderEnabled;
  final String reminderTime;
  final bool soundEnabled;
  
  UserSettings({
    this.reminderEnabled = false,
    this.reminderTime = '20:00',
    this.soundEnabled = true,
  });
  
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderTime: json['reminderTime'] ?? '20:00',
      soundEnabled: json['soundEnabled'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'soundEnabled': soundEnabled,
    };
  }
}