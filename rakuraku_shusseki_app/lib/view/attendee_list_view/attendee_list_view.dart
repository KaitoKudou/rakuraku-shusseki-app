// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/filter_options.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/popup_filter_menu_button_view.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/widget/attendee_add_dialog.dart.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/widget/attendee_name_change_dialog.dart';

class AttendeeListView extends StatefulWidget {
  AttendeeListView({super.key, required this.eventId, required this.isar});
  final Isar isar;
  int eventId;

  @override
  State<AttendeeListView> createState() => _AttendeeListViewState();
}

class _AttendeeListViewState extends State<AttendeeListView> {
  FilterOptions? _selectedFilter;
  late Event event = Event();

  @override
  void initState() {
    loadAttendeesData();
    super.initState();
  }

  // 出欠状況を変更
  Future<void> _updateAttendeeStatus(int index, Status status) async {
    setState(() {
      event.attendee![index].status = status;
    });

    await widget.isar.writeTxn(() async {
      await widget.isar.events.put(event);
    });
  }

  void _filterAttendees(FilterOptions? filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // データベースから参加者データを取得
  Future<void> loadAttendeesData() async {
    final data =
        await widget.isar.events.filter().idEqualTo(widget.eventId).findFirst();
    setState(() {
      if (data != null) {
        event = data;
      }
    });
  }

  // 参加者をデータベースに追加するメソッド
  Future<void> _addAttendeeToEvent(Attendee newAttendee) async {
    event.attendee ??= [];

    // 現在のリストを可変リストに変換
    // Isarでは可変長配列は扱えない
    List<Attendee> mutableAttendeeList = List.from(event.attendee!);
    mutableAttendeeList.insert(0, newAttendee);

    setState(() {
      event.attendee = mutableAttendeeList;
    });

    await widget.isar.writeTxn(
      () async {
        await widget.isar.events.put(event);
      },
    );
  }

  // 参加者の氏名を変更しデータベースを更新
  Future<void> _changeAttendeeName(int index, String newName) async {
    setState(() {
      event.attendee![index].name = newName;
    });

    await widget.isar.writeTxn(() async {
      await widget.isar.events.put(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyView() {
      return const Text('参加者がいません');
    }

    Widget attendeeListView() {
      return ListView.builder(
        itemCount: event.attendee!.length,
        itemBuilder: (context, index) {
          final attendee = event.attendee![index];
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AttendeeNameChangeDialog(
                        previousName: attendee.name,
                        updateAttendeeToEvent: (newName) async {
                          await _changeAttendeeName(index, newName);
                        },
                      );
                    },
                  );
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
            '${event.eventTitle}',
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
              loadAttendeesData();
              showDialog(
                context: context,
                builder: (context) {
                  return AttendeeAddDialog(
                    addAttendeeToEvent: (newAttendee) async {
                      await _addAttendeeToEvent(newAttendee);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: event.attendee == null ? emptyView() : attendeeListView(),
      ),
    );
  }
}
