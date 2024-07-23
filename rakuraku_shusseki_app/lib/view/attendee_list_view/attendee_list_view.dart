import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/filter_options.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/popup_filter_menu_button_view.dart';

class Attendee {
  final String name;
  late String status;

  Attendee({required this.name, required this.status});
}

enum EditStatus {
  newcomer,
  modification,
}

class AttendeeListView extends StatefulWidget {
  const AttendeeListView({super.key});

  @override
  State<AttendeeListView> createState() => _AttendeeListViewState();
}

class _AttendeeListViewState extends State<AttendeeListView> {
  FilterOptions? _selectedFilter;
  final List<Attendee> attendees = [
    Attendee(name: '山田花子', status: '出席'),
    Attendee(name: '鈴木花子', status: '欠席'),
    Attendee(name: '山田太郎', status: '出席'),
    Attendee(name: '鈴木次郎', status: '欠席'),
  ];
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isAddMemberButtonEnabled = ValueNotifier(false);

  @override
  void dispose() {
    _controller.dispose();
    _isAddMemberButtonEnabled.dispose();
    super.dispose();
  }

  void _updateStatus(int index, String status) {
    setState(() {
      attendees[index].status = status;
    });
  }

  void _filterAttendees(FilterOptions? filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<void> _showAddMemberDialog(EditStatus editStatus) async {
    _controller.addListener(() {
      _isAddMemberButtonEnabled.value = _controller.text.isNotEmpty;
    });

    final String title = switch (editStatus) {
      EditStatus.newcomer => 'メンバー追加',
      EditStatus.modification => '名前を変更',
    };
    final String message = switch (editStatus) {
      EditStatus.newcomer => '追加したい人の名前を入力してください。',
      EditStatus.modification => '変更したい名前を入力してください。',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                _controller.text = '';
                Navigator.of(context).pop();
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isAddMemberButtonEnabled,
              builder: (context, isEnabled, child) {
                return TextButton(
                  onPressed: isEnabled
                      ? () {
                          // メンバー追加のロジック
                          _controller.text = '';
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('追加'),
                );
              },
            ),
          ],
        );
      },
    );
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
          PopupFilterMenuButtonView(
            selectedFilter: _selectedFilter,
            onSelected: _filterAttendees,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showAddMemberDialog(EditStatus.newcomer);
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
                onTap: () {
                  debugPrint('${attendee.name}さんの氏名を変更するダイアログを表示');
                  _controller.text = attendee.name;
                  _showAddMemberDialog(EditStatus.modification);
                },
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
