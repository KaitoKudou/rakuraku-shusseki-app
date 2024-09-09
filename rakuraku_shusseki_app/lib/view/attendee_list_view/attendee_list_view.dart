// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/attendee_list_state_notifier.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/widget/popup_filter_menu_button_view.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/widget/attendee_add_dialog.dart.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/widget/attendee_name_change_dialog.dart';

class AttendeeListView extends ConsumerStatefulWidget {
  AttendeeListView({super.key, required this.event});
  Event event;

  @override
  ConsumerState createState() => _AttendeeListViewState();
}

class _AttendeeListViewState extends ConsumerState<AttendeeListView> {
  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<void> _initialize() async {
    await ref
        .read(attendeeListStateNotifierProvider.notifier)
        .initialize(id: widget.event.id);
    await ref
        .read(attendeeListStateNotifierProvider.notifier)
        .loadAttendeesData();
  }

  @override
  Widget build(BuildContext context) {
    final attendees = ref.watch(attendeeListStateNotifierProvider);

    Widget emptyView() {
      return const Text('参加者がいません');
    }

    Widget attendeeListView() {
      return ListView.builder(
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
                      onPressed: () async {
                        await ref
                            .read(attendeeListStateNotifierProvider.notifier)
                            .updateAttendeeStatus(
                                editingTargetEvent: widget.event,
                                targetAttendee: attendee,
                                newStatus: Status.attending);
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
                      onPressed: () async {
                        await ref
                            .read(attendeeListStateNotifierProvider.notifier)
                            .updateAttendeeStatus(
                                editingTargetEvent: widget.event,
                                targetAttendee: attendee,
                                newStatus: Status.absent);
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
                          await ref
                              .read(attendeeListStateNotifierProvider.notifier)
                              .changeAttendeeName(
                                editingTargetEvent: widget.event,
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
            widget.event.eventTitle,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.green.shade600,
        actions: [
          PopupFilterMenuButtonView(
            executeFilterAttendees: () async {
              ref
                  .read(attendeeListStateNotifierProvider.notifier)
                  .filterAttendeesByEvent(event: widget.event);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AttendeeAddDialog(
                    addAttendeeToEvent: (newAttendee) async {
                      await ref
                          .read(attendeeListStateNotifierProvider.notifier)
                          .addAttendeeToEvent(
                            editingTargetEvent: widget.event,
                            newAttendee: newAttendee,
                          );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: attendees.isEmpty ? emptyView() : attendeeListView(),
      ),
    );
  }
}
