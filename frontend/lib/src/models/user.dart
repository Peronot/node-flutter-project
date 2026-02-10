class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final int? doctorId;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.doctorId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] ?? json['role_id'] ?? json['roleId'] ?? 'user';
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: rawRole.toString(),
      doctorId: json['doctor_id'] as int? ?? json['doctorId'] as int?,
    );
  }
}
