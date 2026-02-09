class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}
