class User {
  final String id;
  final String username;
  final String email;
  final String accessToken;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }
}
