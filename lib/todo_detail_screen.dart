import 'package:flutter/material.dart';
import 'model.dart';

class TodoDetailScreen extends StatefulWidget {
  final TodoItem todo;
  final VoidCallback onMemoSaved;
  final List<CustomTag> customTags;

  const TodoDetailScreen({
    Key? key,
    required this.todo,
    required this.onMemoSaved,
    required this.customTags,
  }) : super(key: key);

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TextEditingController _memoController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.todo.memo);
    _textController = TextEditingController(text: widget.todo.text); // 추가
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Color _getTagColor(String tagName) {
    final match = widget.customTags.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => CustomTag(name: tagName, colorValue: Colors.grey.value),
    );
    return match.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text('할 일 상세'),
        backgroundColor: Color(0xFFF2F2F2),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: _getTagColor(widget.todo.tag),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.todo.tag,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '할 일 입력',
                    ),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '마감 기한: ${widget.todo.dueText}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            Text('메모', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            TextField(
              controller: _memoController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '메모를 입력하세요',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF333333),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('메모 저장', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  setState(() {
                    widget.todo.memo = _memoController.text;
                    widget.todo.text = _textController.text;
                  });
                  widget.todo.save(); // Hive 저장!
                  widget.onMemoSaved();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
