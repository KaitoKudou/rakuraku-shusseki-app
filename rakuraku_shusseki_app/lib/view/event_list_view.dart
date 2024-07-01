import 'package:flutter/material.dart';

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'イベント一覧',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.green.shade600,
        ),
        body: const Center(
          child: Text('登録されたイベントがありません'),
        ),
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          onPressed: () {
            // イベント追加画面に遷移
            debugPrint('イベント追加画面に遷移');
          },
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade600,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
