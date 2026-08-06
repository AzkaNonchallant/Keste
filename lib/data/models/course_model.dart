import 'package:flutter/material.dart';

class CourseModel {
  final String id;
  final String UserId;
  final String name;
  final String? lecturer;
  final String? room;
  final Color color;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.UserId,
    required this.name,
    required this.lecturer,
    required this.room,
    required this.color,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json['id'] as String,
    UserId: json['user_id'] as String,
    name: json['name'] as String,
    lecturer: json['lecturer'] as String,
    room: json['room'] as String,
    color: json['color'] != null
            ? Color(int.parse(json['color'] as String, radix: 16))
            : Colors.blue,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': UserId,
    'name': name,
    'lecturer': lecturer,
    'room': room,
    'color': color.value.toRadixString(16),
    'created_at': createdAt
  };
}
