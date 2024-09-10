import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/event_list_state_notifier.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/attendee_list_view.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class EventCreationView extends ConsumerStatefulWidget {
  final bool isEventAddMode;
  final Event? editingTargetEvent;

  const EventCreationView({
    super.key,
    required this.isEventAddMode,
    // ignore: avoid_init_to_null
    this.editingTargetEvent = null,
  });

  @override
  ConsumerState createState() => _EventCreationViewState();
}

class _EventCreationViewState extends ConsumerState<EventCreationView> {
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    _eventTitleController.addListener(_checkIfButtonShouldBeEnabled);
    _dateController.addListener(_checkIfButtonShouldBeEnabled);
    _timeController.addListener(_checkIfButtonShouldBeEnabled);

    if (widget.editingTargetEvent != null) {
      _eventTitleController.text = widget.editingTargetEvent!.eventTitle;
      _dateController.text = widget.editingTargetEvent!.effectiveDate;
      _timeController.text = widget.editingTargetEvent!.startTime;
    }
    super.initState();
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _checkIfButtonShouldBeEnabled() {
    setState(() {
      isButtonEnabled = _eventTitleController.text.isNotEmpty &&
          _dateController.text.isNotEmpty &&
          _timeController.text.isNotEmpty;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (Platform.isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width / 1.5,
            color: Colors.white,
            child: CupertinoDatePicker(
              initialDateTime: DateTime.now(),
              minimumYear: 2000,
              maximumYear: 2101,
              mode: CupertinoDatePickerMode.date,
              backgroundColor: Colors.white,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  _dateController.text =
                      "${dateTime.year}/${dateTime.month}/${dateTime.day}";
                });
              },
            ),
          );
        },
      );
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          _dateController.text = "${picked.year}/${picked.month}/${picked.day}";
        });
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (Platform.isIOS) {
      await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width / 1.5,
            color: Colors.white,
            child: CupertinoDatePicker(
              initialDateTime: DateTime.now(),
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              backgroundColor: Colors.white,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  final formattedTime =
                      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                  _timeController.text = formattedTime;
                });
              },
            ),
          );
        },
      );
    } else {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        setState(() {
          final formattedTime =
              "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
          _timeController.text = formattedTime;
        });
      }
    }
  }

  Future<void> _handleEventOperation() async {
    final bool isEventAddMode = widget.isEventAddMode;
    final title = _eventTitleController.text;
    final date = _dateController.text;
    final time = _timeController.text;
    final eventStateNotifier =
        ref.read(eventListStateNotifierProvider.notifier);
    late Event createdEvent;

    // イベントの作成または編集を実行
    isEventAddMode
        ? createdEvent = await eventStateNotifier.createEvent(
            title: title,
            date: date,
            time: time,
          )
        : await eventStateNotifier.editEvent(
            event: widget.editingTargetEvent!,
            title: title,
            date: date,
            time: time,
          );

    // モーダルを閉じてから、参加者一覧画面に遷移する
    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);

    if (isEventAddMode) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => AttendeeListView(
            event: createdEvent,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 64),
            if (Platform.isIOS)
              CupertinoTextField(
                controller: _eventTitleController,
                placeholder: 'イベント名を入力',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                ),
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            if (!Platform.isIOS)
              TextField(
                controller: _eventTitleController,
                decoration: InputDecoration(
                  labelText: 'イベント名を入力',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            const SizedBox(height: 40),
            Center(
              child: Row(
                children: [
                  Expanded(
                    child: Platform.isIOS
                        ? CupertinoTextField(
                            controller: _dateController,
                            focusNode: AlwaysDisabledFocusNode(),
                            placeholder: '実施日を入力',
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            onTap: () {
                              debugPrint('DatePickerを表示させる');
                              _selectDate(context);
                            },
                            onTapOutside: (_) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          )
                        : TextField(
                            controller: _dateController,
                            focusNode: AlwaysDisabledFocusNode(),
                            decoration: InputDecoration(
                              labelText: '実施日を入力',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade700),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              debugPrint('DatePickerを表示させる');
                              _selectDate(context);
                            },
                            onTapOutside: (_) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Platform.isIOS
                        ? CupertinoTextField(
                            controller: _timeController,
                            focusNode: AlwaysDisabledFocusNode(),
                            placeholder: '開始時刻を入力',
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            onTap: () {
                              debugPrint('DateTimePickerを表示させる');
                              _selectTime(context);
                              (context);
                            },
                            onTapOutside: (_) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          )
                        : TextField(
                            controller: _timeController,
                            focusNode: AlwaysDisabledFocusNode(),
                            decoration: InputDecoration(
                              labelText: '開始時刻を入力',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade700),
                              ),
                            ),
                            readOnly: true,
                            onTap: () {
                              debugPrint('DateTimePickerを表示させる');
                              _selectTime(context);
                            },
                            onTapOutside: (_) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: isButtonEnabled
                    ? () async {
                        await _handleEventOperation();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fixedSize: const Size(240, double.infinity),
                ),
                child: Text(
                  widget.isEventAddMode ? 'イベントを作成' : 'イベントを編集',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
