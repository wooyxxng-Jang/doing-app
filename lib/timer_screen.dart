import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late int focusDuration;
  int restDuration = 10 * 60;
  late int currentDuration;
  bool isFocusTime = true;
  bool isRunning = false;
  Timer? timer;
  int cycleCount = 0;

  @override
  void initState() {
    super.initState();
    final settingsBox = Hive.box('settingsBox');
    int focusMinutes = settingsBox.get('focusMinutes', defaultValue: 25);
    focusDuration = focusMinutes * 60;
    int restMinutes = settingsBox.get('restMinutes', defaultValue: 10);
    restDuration = restMinutes * 60;
    currentDuration = focusDuration;

    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";
    final lastDate = settingsBox.get('cycleDate');
    if (lastDate == today) {
      cycleCount = settingsBox.get('cycleCount', defaultValue: 0);
    } else {
      cycleCount = 0;
      settingsBox.put('cycleDate', today);
      settingsBox.put('cycleCount', 0);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    final settingsBox = Hive.box('settingsBox');
    if (timer != null) timer!.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (currentDuration > 0) {
        setState(() {
          currentDuration--;
        });
      } else {
        setState(() {
          if (isFocusTime == false) {
            cycleCount++;
            final now = DateTime.now();
            final today = "${now.year}-${now.month}-${now.day}";
            settingsBox.put('cycleDate', today);
            settingsBox.put('cycleCount', cycleCount);
          }
          isFocusTime = !isFocusTime;
          currentDuration = isFocusTime ? focusDuration : restDuration;
        });
      }
    });
    setState(() {
      isRunning = true;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<bool> _onWillPop() async {
    final settingsBox = Hive.box('settingsBox');
    if (isRunning) {
      bool? result = await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('타이머 초기화'),
              content: Text('집중 사이클을 멈추지 않고 나가면\n기록이 초기화됩니다.\n계속 하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      cycleCount = 0;
                      isRunning = false;
                      currentDuration = focusDuration;
                      isFocusTime = true;
                    });
                    settingsBox.put('cycleCount', 0);
                    Navigator.of(context).pop(true);
                  },
                  child: Text('확인'),
                ),
              ],
            ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        appBar: AppBar(
          title: Text('집중 타이머'),
          backgroundColor: Color(0xFFF2F2F2),
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, size: 100, color: Color(0xFF333333)),
              SizedBox(height: 20),
              Text(
                isFocusTime ? '집중 시간' : '휴식 시간',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              SizedBox(height: 10),
              Text(
                formatTime(currentDuration),
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              if (!isRunning)
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('타이머 시작하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF333333),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    startTimer();
                  },
                ),
              if (isRunning)
                ElevatedButton.icon(
                  icon: Icon(Icons.stop),
                  label: Text('집중 사이클 멈추기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final settingsBox = Hive.box('settingsBox');
                    timer?.cancel();
                    setState(() {
                      isRunning = false;
                    });
                    settingsBox.put('cycleCount', cycleCount);
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('집중 사이클 종료'),
                            content: Text('현재까지 완료한 집중 사이클은 $cycleCount회입니다.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('확인'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              SizedBox(height: 20),
              Text(
                '나의 집중 사이클: $cycleCount회',
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
