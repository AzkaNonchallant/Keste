class ScheduleModel {
  final String id;
  final String courseId;
  final String day; 
  final String startTime;
  final String endTime; 
  final DateTime createdAt;
  final String? courseName;
  final String? room;

  ScheduleModel({
    required this.id,
    required this.courseId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.courseName,
    this.room,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        day: json['day'] as String,
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        courseName: json['courses']?['name'] as String?,
        room: json['courses']?['room'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'course_id': courseId,
        'day': day,
        'start_time': startTime,
        'end_time': endTime,
      };
}