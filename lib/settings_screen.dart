import 'model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  final List<CustomTag> tags;
  const SettingsScreen({Key? key, required this.tags}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box<CustomTag> tagBox;
  late Box settingsBox;

  late List<CustomTag> customTags;
  late int focusMinutes;
  late int restMinutes;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    tagBox = Hive.box<CustomTag>('tagBox');
    settingsBox = Hive.box('settingsBox');

    customTags = List<CustomTag>.from(widget.tags);
    focusMinutes = settingsBox.get('focusMinutes', defaultValue: 25);
    restMinutes = settingsBox.get('restMinutes', defaultValue: 10);
  }

  Future<void> _showAddTagDialog() async {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    final List<Color> colorOptions = [
      const Color.fromARGB(255, 255, 197, 193),
      const Color.fromARGB(255, 199, 255, 201),
      const Color.fromARGB(255, 198, 229, 255),
      const Color.fromARGB(255, 255, 231, 195),
      const Color.fromARGB(255, 247, 200, 255),
    ];
    await showDialog(
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
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children:
                        colorOptions.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setStateDialog(() {
                                selectedColor = color;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: color,
                              child:
                                  selectedColor == color
                                      ? Icon(Icons.check, color: Colors.white)
                                      : null,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty &&
                        !customTags.any((t) => t.name == name)) {
                      setState(() {
                        customTags.add(
                          CustomTag(
                            name: name,
                            colorValue: selectedColor.value,
                          ),
                        );
                        isChanged = true;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTag(CustomTag tag) {
    setState(() {
      customTags.remove(tag);
      isChanged = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!isChanged) return true;
    bool? discard = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('변경 사항 감지'),
            content: Text('저장하지 않은 변경 사항이 있습니다. 변경 사항을 버리고 나가시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('변경 사항 버리기'),
              ),
            ],
          ),
    );
    return discard ?? false;
  }

  void _saveSettings() async {
    // Save tags to Hive
    await tagBox.clear();
    for (final tag in customTags) {
      await tagBox.add(tag);
    }
    // Save focus/rest times
    await settingsBox.put('focusMinutes', focusMinutes);
    await settingsBox.put('restMinutes', restMinutes);
    setState(() {
      isChanged = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('설정이 저장되었습니다')));
    Navigator.of(context).pop(customTags);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: Text('설정')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '집중 시간 (분)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: focusMinutes.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 50,
                        label: focusMinutes.toString(),
                        onChanged: (value) {
                          setState(() {
                            focusMinutes = value.round();
                            isChanged = true;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('$focusMinutes분'),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  '휴식 시간 (분)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: restMinutes.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 25,
                        label: restMinutes.toString(),
                        onChanged: (value) {
                          setState(() {
                            restMinutes = value.round();
                            isChanged = true;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('$restMinutes분'),
                  ],
                ),
                SizedBox(height: 24),
                Text('태그 관리', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                      customTags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag.name,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: tag.color,
                              deleteIcon: Icon(Icons.close, size: 18),
                              onDeleted: () => _deleteTag(tag),
                            ),
                          )
                          .toList(),
                ),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _showAddTagDialog,
                  icon: Icon(Icons.add),
                  label: Text('태그 추가'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isChanged ? _saveSettings : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('저장', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
