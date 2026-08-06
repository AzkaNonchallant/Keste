enum AnnouncementType { academic, holiday, scheduleChange, administration }

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final AnnouncementType type;
  final String createdBy;
  final DateTime publishedAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdBy,
    required this.publishedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) => AnnouncementModel(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        type: AnnouncementType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AnnouncementType.academic,
        ),
        createdBy: json['created_by'] as String,
        publishedAt: DateTime.parse(json['published_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'type': type.name,
        'created_by': createdBy,
      };
}