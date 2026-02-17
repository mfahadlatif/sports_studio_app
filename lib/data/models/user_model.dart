class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? phone;
  final String? appleId;
  final String? googleId;
  final bool isPhoneVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
    this.appleId,
    this.googleId,
    this.isPhoneVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      phone: json['phone'],
      appleId: json['apple_id'],
      googleId: json['google_id'],
      isPhoneVerified: json['is_phone_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'phone': phone,
      'apple_id': appleId,
      'google_id': googleId,
      'is_phone_verified': isPhoneVerified,
    };
  }
}
