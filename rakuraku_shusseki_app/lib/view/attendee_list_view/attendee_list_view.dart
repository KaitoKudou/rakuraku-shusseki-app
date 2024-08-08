// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/widget/popup_filter_menu_button_view.dart';
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
  Status? _selectedStatus;
  late Event allEvent = Event();
  late Event filteredEvent = Event();

  @override
  void initState() {
    loadAttendeesData();
    super.initState();
  }

  // 出欠状況を変更
  Future<void> _updateAttendeeStatus(
      {required Attendee target, required Status newStatus}) async {
    final index =
        allEvent.attendee.indexWhere((attendee) => attendee == target);

    // indexWhereはマッチしなければ -1 を返す
    if (index != -1) {
      setState(() {
        allEvent.attendee[index].status = newStatus;
      });

      await widget.isar.writeTxn(() async {
        await widget.isar.events.put(allEvent);
      });
    }
  }

  // 指定された条件で参加者を絞り込み
  void _filterAttendees(Status? selected) {
    final filteredAttendees = allEvent.attendee.where(
      (attendee) {
        return attendee.status == selected;
      },
    ).toList();

    setState(() {
      _selectedStatus = selected;

      if (selected != null) {
        filteredEvent.attendee = filteredAttendees;
      }
    });
  }

  // データベースから参加者データを取得
  Future<void> loadAttendeesData() async {
    final data =
        await widget.isar.events.filter().idEqualTo(widget.eventId).findFirst();
    setState(() {
      if (data != null) {
        allEvent = data;
      }
    });
  }

  // 参加者をデータベースに追加するメソッド
  Future<void> _addAttendeeToEvent(Attendee newAttendee) async {
    // 現在のリストを可変リストに変換
    // Isarでは可変長配列は扱えない
    List<Attendee> mutableAllAttendeeList = List.from(allEvent.attendee);
    mutableAllAttendeeList.insert(0, newAttendee);

    setState(() {
      allEvent.attendee = mutableAllAttendeeList;
    });

    await widget.isar.writeTxn(
      () async {
        await widget.isar.events.put(allEvent);
      },
    );

    _filterAttendees(_selectedStatus);
  }

  // 参加者の氏名を変更しデータベースを更新
  Future<void> _changeAttendeeName(
      {required String previousName, required String newName}) async {
    final indexForAllEvent = allEvent.attendee
        .indexWhere((attendee) => attendee.name == previousName);
    final indexForFilteredEvent = filteredEvent.attendee
        .indexWhere((attendee) => attendee.name == previousName);

    // indexWhereはマッチしなければ -1 を返す
    if (indexForAllEvent != -1 || indexForFilteredEvent != -1) {
      setState(() {
        allEvent.attendee[indexForAllEvent].name = newName;
        if (_selectedStatus != null) {
          filteredEvent.attendee[indexForFilteredEvent].name = newName;
        }
      });

      await widget.isar.writeTxn(() async {
        await widget.isar.events.put(allEvent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyView() {
      return const Text('参加者がいません');
    }

    Widget attendeeListView(Event event) {
      return ListView.builder(
        itemCount: event.attendee.length,
        itemBuilder: (context, index) {
          final attendee = event.attendee[index];
          return Column(
            children: [
              ListTile(
                title: Text(attendee.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _updateAttendeeStatus(
                          target: attendee,
                          newStatus: Status.attending,
                        );
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
                        _updateAttendeeStatus(
                          target: attendee,
                          newStatus: Status.absent,
                        );
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
                          await _changeAttendeeName(
                            previousName: attendee.name,
                            newName: newName,
                          );
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
            '${allEvent.eventTitle}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.green.shade600,
        actions: [
          PopupFilterMenuButtonView(
            selectedFilter: _selectedStatus,
            executeFilterAttendees: (selected) {
              _filterAttendees(selected);
            },
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
        child: allEvent.attendee.isEmpty ||
                (filteredEvent.attendee.isEmpty && _selectedStatus != null)
            ? emptyView()
            : attendeeListView(
                _selectedStatus == null ? allEvent : filteredEvent,
              ),
      ),
    );
  }
}
