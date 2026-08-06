class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String? nim;
  final String? major;
  final int? semester;
  final String? photoUrl;
  final String role; 
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.nim,
    this.major,
    this.semester,
    this.photoUrl,
    this.role = 'student',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        nim: json['nim'] as String?,
        major: json['major'] as String?,
        semester: json['semester'] as int?,
        photoUrl: json['photo_url'] as String?,
        role: json['role'] as String? ?? 'student',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'nim': nim,
        'major': major,
        'semester': semester,
        'photo_url': photoUrl,
        'role': role,
      };

  bool get isAdmin => role == 'admin';

  ProfileModel copyWith({
    String? fullName,
    String? nim,
    String? major,
    int? semester,
    String? photoUrl,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      nim: nim ?? this.nim,
      major: major ?? this.major,
      semester: semester ?? this.semester,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}