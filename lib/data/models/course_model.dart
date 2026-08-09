import 'package:flutter/material.dart';

class CourseModel {
  final String id;
  final String userId;
  final String name;
  final String? lecturer;
  final String? room;
  final Color color;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.lecturer,
    required this.room,
    required this.color,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      lecturer: json['lecturer'] as String?,
      room: json['room'] as String?,
      color: json['color'] != null
          ? Color(
              int.parse(
                json['color'] as String,
                radix: 16,
              ),
            )
          : Colors.blue,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'lecturer': lecturer,
      'room': room,
      'color': color.value.toRadixString(16),
      'created_at': createdAt.toIso8601String(),
    };
  }
}