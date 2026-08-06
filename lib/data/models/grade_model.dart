class GradeModel {
  final String id;
  final String courseId;
  final double? uts;
  final double? uas;
  final double? assignment;
  final double? finalGrade;

  final String? courseName;

  GradeModel({
    required this.id,
    required this.courseId,
    this.uts,
    this.uas,
    this.assignment,
    this.finalGrade,
    this.courseName,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) => GradeModel(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        uts: (json['uts'] as num?)?.toDouble(),
        uas: (json['uas'] as num?)?.toDouble(),
        assignment: (json['assignment'] as num?)?.toDouble(),
        finalGrade: (json['final_grade'] as num?)?.toDouble(),
        courseName: json['courses']?['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        'uts': uts,
        'uas': uas,
        'assignment': assignment,
        'final_grade': finalGrade,
      };
}