class AssignmentModel {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final DateTime deadline;
  final AssignmentPriority priority;
  final AssignmentStatus status;
  final String? submissionFileUrl;
  final DateTime createdAt;
  final String? courseName;

  AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.deadline,
    this.priority = AssignmentPriority.medium,
    this.status = AssignmentStatus.todo,
    this.submissionFileUrl,
    required this.createdAt,
    this.courseName,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        deadline: DateTime.parse(json['deadline'] as String),
        priority: AssignmentPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => AssignmentPriority.medium,
        ),
        status: AssignmentStatus.values.firstWhere(
          (e) => e.name.replaceAll('inProgress', 'in_progress') == json['status'],
          orElse: () => AssignmentStatus.todo,
        ),
        submissionFileUrl: json['submission_file_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        courseName: json['courses']?['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'priority': priority.name,
        'status': status.name == 'inProgress' ? 'in_progress' : status.name,
      };

  bool get isOverdue => status != AssignmentStatus.completed && deadline.isBefore(DateTime.now());
}

enum AssignmentStatus { todo, inProgress, completed }
enum AssignmentPriority { low, medium, high }