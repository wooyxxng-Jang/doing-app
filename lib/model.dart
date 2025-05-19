import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class TodoItem extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  String tag;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  String memo;

  TodoItem({
    required this.text,
    required this.tag,
    this.dueDate,
    this.isDone = false,
    this.memo = '',
  });

  String get dueText {
    if (dueDate == null) return '마감 기한 없음';
    return '${dueDate!.month}/${dueDate!.day} ${dueDate!.hour.toString().padLeft(2, '0')}:${dueDate!.minute.toString().padLeft(2, '0')}';
  }
}

@HiveType(typeId: 1)
class CustomTag extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int colorValue;

  CustomTag({required this.name, required this.colorValue});

  factory CustomTag.fromColor({required String name, required Color color}) {
    return CustomTag(name: name, colorValue: color.value);
  }

  Color get color => Color(colorValue);
}
