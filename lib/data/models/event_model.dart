class EventModel {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime eventDate;
  final String? imageUrl;
  final String createdBy;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.eventDate,
    this.imageUrl,
    required this.createdBy,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        location: json['location'] as String?,
        eventDate: DateTime.parse(json['event_date'] as String),
        imageUrl: json['image_url'] as String?,
        createdBy: json['created_by'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'location': location,
        'event_date': eventDate.toIso8601String(),
        'image_url': imageUrl,
        'created_by': createdBy,
      };

  bool get isUpcoming => eventDate.isAfter(DateTime.now());
}