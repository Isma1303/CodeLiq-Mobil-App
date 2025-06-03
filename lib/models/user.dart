class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.password,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] != null
          ? json['created_at'] is String
                ? DateTime.parse(json['created_at'])
                : DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : DateTime.now(),
      password: json['password'],
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      if (password != null) 'password': password,
    };
  }
}
