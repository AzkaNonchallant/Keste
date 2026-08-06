class MaterialModel {
  final String id;
  final String courseId;
  final String title;
  final String fileUrl;
  final DateTime uploadedAt;

  final String? courseName;

  MaterialModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.fileUrl,
    required this.uploadedAt,
    this.courseName,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        title: json['title'] as String,
        fileUrl: json['file_url'] as String,
        uploadedAt: DateTime.parse(json['uploaded_at'] as String),
        courseName: json['courses']?['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        'title': title,
        'file_url': fileUrl,
      };

  String get extension => fileUrl.split('.').last.toLowerCase();
}