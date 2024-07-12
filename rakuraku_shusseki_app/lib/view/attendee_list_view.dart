import 'package:flutter/material.dart';

class Attendee {
  final String name;
  late String status;

  Attendee({required this.name, required this.status});
}

class AttendeeListView extends StatefulWidget {
  const AttendeeListView({super.key});

  @override
  State<AttendeeListView> createState() => _AttendeeListViewState();
}

class _AttendeeListViewState extends State<AttendeeListView> {
  final List<Attendee> attendees = [
    Attendee(name: '山田花子', status: '出席'),
    Attendee(name: '山田花子', status: '欠席'),
    Attendee(name: '山田太郎', status: '出席'),
    Attendee(name: '鈴木次郎', status: '欠席'),
  ];

  void _updateStatus(int index, String status) {
    setState(() {
      attendees[index].status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Text(
            'イベント作成',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.green.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              debugPrint('フィルター処理を実行');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              debugPrint('参加者追加処理を実行');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: attendees.length,
        itemBuilder: (context, index) {
          final attendee = attendees[index];
          return Column(
            children: [
              ListTile(
                title: Text(attendee.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateStatus(index, '出席');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: attendee.status == '出席'
                            ? Colors.green.shade600
                            : Colors.grey.shade400,
                      ),
                      child: const Text(
                        '出席',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _updateStatus(index, '欠席');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: attendee.status == '欠席'
                            ? Colors.red.shade400
                            : Colors.grey.shade400,
                      ),
                      child: const Text(
                        '欠席',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: Colors.grey.shade400,
                  thickness: 1,
                  height: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
