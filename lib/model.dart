import 'package:flutter/material.dart';

class TodoItem {
  String tag;
  String text;
  String dueText;
  DateTime? dueDate;
  bool isDone;
  String memo;

  TodoItem({
    required this.tag,
    required this.text,
    required this.dueText,
    required this.dueDate,
    this.isDone = false,
    this.memo = '',
  });
}

class CustomTag {
  String name;
  Color color;

  CustomTag({required this.name, required this.color});
}
