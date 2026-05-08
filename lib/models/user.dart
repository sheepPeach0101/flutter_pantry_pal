/// 用户信息模型
class User {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final String? role;
  final String? phone;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    this.role,
    this.phone,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// 认证成功返回数据（用户信息 + Token）
class AuthData {
  final User user;
  final String token;

  AuthData({
    required this.user,
    required this.token,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
