// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/filter_options.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/popup_filter_menu_button_view.dart';

enum EditStatus {
  newcomer,
  modification,
}

class AttendeeListView extends StatefulWidget {
  AttendeeListView({super.key, required this.event, required this.isar});
  final Isar isar;
  Event event;

  @override
  State<AttendeeListView> createState() => _AttendeeListViewState();
}

class _AttendeeListViewState extends State<AttendeeListView> {
  FilterOptions? _selectedFilter;
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isAddMemberButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    loadAttendeesData();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isAddMemberButtonEnabled.dispose();
    super.dispose();
  }

  // 出欠状況を変更
  Future<void> _updateAttendeeStatus(int index, Status status) async {
    setState(() {
      widget.event.attendee![index].status = status;
    });

    await widget.isar.writeTxn(() async {
      await widget.isar.events.put(widget.event);
    });
  }

  void _filterAttendees(FilterOptions? filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // データベースから参加者データを取得
  Future<void> loadAttendeesData() async {
    final data = await widget.isar.events
        .filter()
        .idEqualTo(widget.event.id)
        .findFirst();
    setState(() {
      if (data != null) {
        widget.event = data;
      }
    });
  }

  // 参加者をデータベースに追加するメソッド
  Future<void> _addAttendeeToEvent() async {
    widget.event.attendee ??= [];

    // 現在のリストを可変リストに変換
    // Isarでは可変長配列は扱えない
    List<Attendee> mutableAttendeeList = List.from(widget.event.attendee!);

    Attendee newAttendee = Attendee()
      ..name = _controller.text
      ..status = Status.attending;

    mutableAttendeeList.insert(0, newAttendee);

    setState(() {
      widget.event.attendee = mutableAttendeeList;
    });

    _controller.text = '';

    await widget.isar.writeTxn(
      () async {
        await widget.isar.events.put(widget.event);
      },
    );
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
                      ? () async {
                          await _addAttendeeToEvent();
                          // ignore: use_build_context_synchronously
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
    Widget emptyView() {
      return const Text('参加者がいません');
    }

    Widget attendeeListView() {
      return ListView.builder(
        itemCount: widget.event.attendee!.length,
        itemBuilder: (context, index) {
          final attendee = widget.event.attendee![index];
          return Column(
            children: [
              ListTile(
                title: Text(attendee.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateAttendeeStatus(index, Status.attending);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: attendee.status == Status.attending
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
                        _updateAttendeeStatus(index, Status.absent);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: attendee.status == Status.absent
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(
          child: Text(
            '${widget.event.eventTitle}',
            style: const TextStyle(color: Colors.white),
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
      body: Center(
        child: widget.event.attendee == null ? emptyView() : attendeeListView(),
      ),
    );
  }
}
