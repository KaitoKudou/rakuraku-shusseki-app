import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/attendee_list_view.dart';

class EventCreationView extends StatefulWidget {
  final Isar isar;
  final bool isEventAddMode;
  final Event? editingTargetEvent;

  const EventCreationView({
    super.key,
    required this.isar,
    required this.isEventAddMode,
    // ignore: avoid_init_to_null
    this.editingTargetEvent = null,
  });

  @override
  State<EventCreationView> createState() => _EventCreationViewState();
}

class _EventCreationViewState extends State<EventCreationView> {
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  late Event event = Event();

  @override
  void initState() {
    if (widget.editingTargetEvent != null) {
      _eventTitleController.text = widget.editingTargetEvent!.eventTitle!;
      _dateController.text = widget.editingTargetEvent!.effectiveDate!;
      _timeController.text = widget.editingTargetEvent!.startTime!;
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

  Future<void> _selectDate(BuildContext context) async {
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

  Future<void> _selectTime(BuildContext context) async {
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

  Future<void> _createEvent() async {
    event
      ..eventTitle = _eventTitleController.text
      ..effectiveDate = _dateController.text
      ..startTime = _timeController.text;

    await widget.isar.writeTxn(() async {
      await widget.isar.events.put(event);
    });
  }

  Future<void> _editEvent() async {
    widget.editingTargetEvent
      ?..eventTitle = _eventTitleController.text
      ..effectiveDate = _dateController.text
      ..startTime = _timeController.text;
    await widget.isar.writeTxn(() async {
      await widget.isar.events.put(widget.editingTargetEvent!);
    });
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
            TextField(
              controller: _eventTitleController,
              decoration: InputDecoration(
                labelText: 'イベント名を入力',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade700),
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
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: '実施日を入力',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
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
                    child: TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: '開始時刻を入力',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade700),
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
                onPressed: () async {
                  final bool isEventAddMode = widget.isEventAddMode;

                  // イベントの作成または編集を実行
                  isEventAddMode ? await _createEvent() : await _editEvent();

                  // モーダルを閉じてから、参加者一覧画面に遷移する
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, true);

                  if (isEventAddMode) {
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendeeListView(
                          eventId: event.id,
                          isar: widget.isar,
                        ),
                      ),
                    );
                  }
                },
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
