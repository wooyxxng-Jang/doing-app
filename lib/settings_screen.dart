import 'package:flutter/material.dart';
import 'model.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  final List<CustomTag> tags;
  const SettingsScreen({super.key, required this.tags});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<CustomTag> customTags;

  @override
  void initState() {
    super.initState();
    customTags = List.from(widget.tags);
  }

  void _addTag() {
    TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.indigo;
    final List<Color> tagColors = [
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF42A5F5),
      Color(0xFF26A69A),
      Color(0xFF66BB6A),
      Color(0xFFFFA726),
      Color(0xFF555555),
      Color(0xFFBDBDBD),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('태그 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: '태그 이름'),
                    onChanged: (_) => setStateDialog(() {}),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      Color? picked = await showDialog<Color>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text("색상 선택"),
                              content: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children:
                                      tagColors.map((color) {
                                        return GestureDetector(
                                          onTap:
                                              () => Navigator.of(
                                                context,
                                              ).pop(color),
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.black26,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                      );

                      if (picked != null) {
                        setStateDialog(() {
                          selectedColor = picked;
                        });
                      }
                    },
                    child: Text(
                      nameController.text.trim().isNotEmpty
                          ? nameController.text.trim()
                          : '색상 변경',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('취소'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text('추가'),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final newTag = CustomTag.fromColor(
                        name: nameController.text.trim(),
                        color: selectedColor,
                      );

                      setState(() {
                        customTags.add(newTag);
                      });

                      Hive.box<CustomTag>('tagBox').add(newTag);

                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTag(int index) {
    setState(() {
      customTags.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, customTags);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('설정')),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              "사용자 태그",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  customTags.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tag = entry.value;
                    return Chip(
                      label: Text(
                        tag.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: tag.color,
                      deleteIcon: Icon(Icons.close, color: Colors.white),
                      onDeleted: () => _deleteTag(index),
                    );
                  }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addTag,
              icon: Icon(Icons.add),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text("태그 추가", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
