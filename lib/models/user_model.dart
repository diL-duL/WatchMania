class UserProfile {
  final String id;
  final String email;
  final String nama;
  final String role;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nama: json['nama'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
    };
  }
}
