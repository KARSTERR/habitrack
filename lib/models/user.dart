class User {
  final String id; // Change type to String if possible
  final String username;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle different ID types coming from backend (could be int64 or string)
    String userId;
    var rawId = json['id'];
    if (rawId is int) {
      userId = rawId.toString();
    } else if (rawId is String) {
      userId = rawId;
    } else {
      throw FormatException('Unexpected ID format: ${rawId.runtimeType}');
    }

    return User(
      id: userId,
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
