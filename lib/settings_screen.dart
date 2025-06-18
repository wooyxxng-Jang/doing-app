import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'model.dart';

class SettingsScreen extends StatefulWidget {
  final List<CustomTag> tags;
  const SettingsScreen({Key? key, required this.tags}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<CustomTag> _tags;
  double _focusDuration = 25;
  int _restDuration = 5;

  final List<int> _restOptions = [1, 5, 10, 15];

  // For new tag input
  final TextEditingController _tagNameController = TextEditingController();
  Color _newTagColor = Colors.blue;

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _tags = List<CustomTag>.from(widget.tags);

    final settingsBox = Hive.box('settingsBox');
    _focusDuration = (settingsBox.get('focusMinutes') ?? 25).toDouble();
    _restDuration = settingsBox.get('restMinutes') ?? 5;
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('저장되지 않았습니다'),
              content: Text('설정을 저장하지 않고 나가시겠습니까?'),
              actions: [
                TextButton(
                  child: Text('취소'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('나가기'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
      );
      return shouldLeave ?? false;
    }
    return true;
  }

  void _showAddTagDialog() {
    _tagNameController.clear();
    _newTagColor = Colors.white;
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
                    controller: _tagNameController,
                    decoration: InputDecoration(labelText: '태그 이름'),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text('색상:'),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          Color? color = await showDialog<Color>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('색상 선택'),
                                  content: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: 8,
                                      children: [
                                        ...[
                                          const Color.fromARGB(
                                            255,
                                            255,
                                            213,
                                            210,
                                          ),
                                          const Color.fromARGB(
                                            255,
                                            197,
                                            255,
                                            199,
                                          ),
                                          const Color.fromARGB(
                                            255,
                                            190,
                                            226,
                                            255,
                                          ),
                                          const Color.fromARGB(
                                            255,
                                            255,
                                            224,
                                            177,
                                          ),
                                          const Color.fromARGB(
                                            255,
                                            246,
                                            197,
                                            255,
                                          ),
                                          const Color.fromARGB(
                                            255,
                                            190,
                                            255,
                                            249,
                                          ),
                                          const Color.fromARGB(
                                            255,
                                            255,
                                            199,
                                            218,
                                          ),
                                          const Color.fromARGB(
                                            255,
                                            166,
                                            166,
                                            166,
                                          ),
                                        ].map(
                                          (color) => GestureDetector(
                                            onTap:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(color),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              margin: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      _newTagColor == color
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          );
                          if (color != null) {
                            setState(() {
                              _newTagColor = color;
                            });
                            setStateDialog(() {});
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _newTagColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('취소'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('추가'),
                  onPressed: () {
                    final name = _tagNameController.text.trim();
                    if (name.isNotEmpty &&
                        !_tags.any((tag) => tag.name == name)) {
                      setState(() {
                        _tags.add(
                          CustomTag(name: name, colorValue: _newTagColor.value),
                        );
                        _hasUnsavedChanges = true;
                      });
                      Navigator.of(context).pop();
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

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
      _hasUnsavedChanges = true;
    });
  }

  Widget _tagChip(CustomTag tag, int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Chip(
        label: Text(tag.name, style: TextStyle(color: Color(0xFF333333))),
        backgroundColor: tag.color,
        deleteIcon: Icon(Icons.close, color: Color(0xFF333333)),
        onDeleted: () => _removeTag(idx),
        shape: StadiumBorder(side: BorderSide.none),
        elevation: 0,
      ),
    );
  }

  Widget _addChip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ActionChip(
        avatar: Icon(Icons.add, color: Color(0xFF333333)),
        label: Text('추가', style: TextStyle(color: Color(0xFF333333))),
        backgroundColor: Colors.grey[200],
        shape: StadiumBorder(),
        onPressed: _showAddTagDialog,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: Text('설정')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '집중 타이머 시간',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Slider(
                  min: 1,
                  max: 60,
                  divisions: 59,
                  value: _focusDuration,
                  label: '${_focusDuration.round()}분',
                  onChanged:
                      (v) => setState(() {
                        _focusDuration = v;
                        _hasUnsavedChanges = true;
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1분'),
                      Text(
                        '${_focusDuration.round()}분',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('60분'),
                    ],
                  ),
                ),
                Text(
                  '휴식 타이머 시간',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: DropdownButton<int>(
                    value: _restDuration,
                    items:
                        _restOptions
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text('$m분'),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (v) => setState(() {
                          _restDuration = v!;
                          _hasUnsavedChanges = true;
                        }),
                  ),
                ),
                Text(
                  '커스텀 태그 관리',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ..._tags.asMap().entries.map(
                      (e) => _tagChip(e.value, e.key),
                    ),
                    _addChip(),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                      final settingsBox = Hive.box('settingsBox');
                      settingsBox.put('focusMinutes', _focusDuration.round());
                      settingsBox.put('restMinutes', _restDuration);
                      _hasUnsavedChanges = false;
                      Navigator.of(context).pop(_tags);
                    },
                    child: Text('저장하기', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
