import 'package:flutter/material.dart';
import 'package:doing_app/settings_screen.dart' as settings;
import 'package:doing_app/timer_screen.dart' as timer;
import 'todo_detail_screen.dart';
import 'model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TodoItemAdapter());
  Hive.registerAdapter(CustomTagAdapter());

  await Hive.openBox<TodoItem>('todoBox');
  await Hive.openBox<CustomTag>('tagBox');
  await Hive.openBox('settingsBox');

  runApp(DoingApp());
}

class DoingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doing',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF2F2F2),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF2F2F2),
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF333333),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
        ),
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: Colors.black87, fontFamily: 'Pretendard'),
        cardColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF333333),
          secondary: Color(0xFF333333),
          surface: Colors.white,
          background: Color(0xFFF2F2F2),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
          brightness: Brightness.light,
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final todoBox = Hive.box<TodoItem>('todoBox');
    final tagBox = Hive.box<CustomTag>('tagBox');

    setState(() {
      todoList = todoBox.values.toList();
      customTags = tagBox.values.toList();
    });
  }

  List<CustomTag> customTags = [];
  List<TodoItem> todoList = [];

  Color _getTagColor(String tagName) {
    final match = customTags.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => CustomTag(name: tagName, colorValue: Colors.grey.value),
    );
    return match.color;
  }

  void _addTodo() {
    TextEditingController textController = TextEditingController();
    DateTime? selectedDateTime;
    CustomTag? selectedTag;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (selectedTag == null && customTags.isNotEmpty) {
              selectedTag = customTags[0];
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('할 일 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('태그:'),
                        SizedBox(width: 10),
                        DropdownButton<CustomTag>(
                          value: selectedTag,
                          onChanged: (CustomTag? newValue) {
                            setStateDialog(() {
                              selectedTag = newValue;
                            });
                          },
                          items:
                              customTags.map((tag) {
                                return DropdownMenuItem(
                                  value: tag,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: tag.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(tag.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(labelText: '할 일 내용'),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(Icons.calendar_today),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          selectedDateTime != null
                              ? '${selectedDateTime!.month}/${selectedDateTime!.day} '
                                  '${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}'
                              : '마감 기한 선택',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: Color(0xFF333333),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        DateTime now = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 1),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dialogBackgroundColor: Colors.white),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 23, minute: 59),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dialogBackgroundColor: Colors.white),
                                child: child!,
                              );
                            },
                          );
                          if (pickedTime != null) {
                            setStateDialog(() {
                              selectedDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('취소'),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('추가'),
                  ),
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      final newTodo = TodoItem(
                        tag: selectedTag?.name ?? '기본',
                        text: textController.text.trim(),
                        dueDate: selectedDateTime,
                        memo: '',
                      );

                      setState(() {
                        todoList.add(newTodo);
                      });

                      Hive.box<TodoItem>('todoBox').add(newTodo);

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

  void _deleteTodos() {
    List<int> selectedIndexes = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('삭제할 할 일을 선택하세요'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: todoList.length,
                  itemBuilder: (context, index) {
                    final todo = todoList[index];
                    final isSelected = selectedIndexes.contains(index);

                    return Card(
                      color: isSelected ? Colors.grey[100] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                        value: isSelected,
                        title: Text('[${todo.tag}] ${todo.text}'),
                        subtitle: Text('~ ${todo.dueText}'),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setStateDialog(() {
                            if (value == true) {
                              selectedIndexes.add(index);
                            } else {
                              selectedIndexes.remove(index);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('취소'),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('삭제'),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndexes.sort((a, b) => b.compareTo(a));
                      for (int index
                          in selectedIndexes..sort((a, b) => b.compareTo(a))) {
                        Hive.box<TodoItem>('todoBox').deleteAt(index);
                        todoList.removeAt(index);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getToday() {
    DateTime now = DateTime.now();
    return '${now.month}/${now.day}(${["일", "월", "화", "수", "목", "금", "토"][now.weekday % 7]})';
  }

  String _weekdayToString(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[(weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    List<TodoItem> incompleteList =
        todoList.where((item) => !item.isDone).toList();

    incompleteList.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) {
        int tagComp = a.tag.compareTo(b.tag);
        if (tagComp != 0) return tagComp;
        return a.text.compareTo(b.text);
      }
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;

      int dateComparison = a.dueDate!.compareTo(b.dueDate!);
      if (dateComparison != 0) return dateComparison;

      int tagComparison = a.tag.compareTo(b.tag);
      if (tagComparison != 0) return tagComparison;

      return a.text.compareTo(b.text);
    });

    List<TodoItem> completedList =
        todoList.where((item) => item.isDone).toList();

    Widget buildSection(String title, List<TodoItem> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 0, 6),
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('항목이 없습니다.', style: TextStyle(color: Colors.grey)),
            ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final todo = entry.value;
            final now = DateTime.now();
            final isDueToday =
                todo.dueDate != null &&
                todo.dueDate!.year == now.year &&
                todo.dueDate!.month == now.month &&
                todo.dueDate!.day == now.day;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Card(
                elevation: 2,
                color: todo.isDone ? Colors.grey[200] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading:
                        todo.isDone
                            ? null
                            : Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '${index + 1}.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                    title: Row(
                      children: [
                        if (isDueToday)
                          Container(
                            margin: EdgeInsets.only(right: 6),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '오늘 마감',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Container(
                          margin: EdgeInsets.only(right: 6),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTagColor(todo.tag),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            todo.tag,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            todo.text,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '~ ${todo.dueText}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (bool? value) {
                        setState(() {
                          todo.isDone = value ?? false;
                        });
                        todo.save();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TodoDetailScreen(
                                todo: todo,
                                customTags: customTags,
                                onMemoSaved: () => setState(() {}),
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _getToday(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => settings.SettingsScreen(tags: customTags),
                ),
              );

              if (result != null && result is List<CustomTag>) {
                setState(() {
                  customTags = result;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text("할 일 추가", style: TextStyle(fontSize: 16)),
                    ),
                    onPressed: _addTodo,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text("할 일 삭제", style: TextStyle(fontSize: 16)),
                    ),
                    onPressed: _deleteTodos,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                buildSection('해야 하는 일', incompleteList),
                buildSection('완료된 일', completedList),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.timer),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text("집중 타이머 시작", style: TextStyle(fontSize: 18)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => timer.TimerScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
