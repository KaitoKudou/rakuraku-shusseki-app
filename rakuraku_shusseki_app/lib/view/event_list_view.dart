import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/view/event_creation_view.dart';

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'イベント一覧',
            style: TextStyle(color: Colors.white),
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EventCreationView()));
          },
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade600,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
