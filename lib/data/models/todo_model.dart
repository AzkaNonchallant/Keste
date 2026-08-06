class TodoModel {
  final String id;
  final String userId;
  final String title;
  final bool completed;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.completed = false,
    required this.createdAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'title': title,
        'completed': completed,
      };

  TodoModel copyWith({String? title, bool? completed}) => TodoModel(
        id: id,
        userId: userId,
        title: title ?? this.title,
        completed: completed ?? this.completed,
        createdAt: createdAt,
      );
}