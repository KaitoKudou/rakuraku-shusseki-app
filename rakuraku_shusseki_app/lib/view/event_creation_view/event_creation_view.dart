import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/event_list_state_notifier.dart';
import 'package:rakuraku_shusseki_app/utils/date_time_picker_utils.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/attendee_list_view.dart';
import 'package:rakuraku_shusseki_app/view/event_creation_view/widget/date_text_field.dart';
import 'package:rakuraku_shusseki_app/view/event_creation_view/widget/event_title_text_field.dart';
import 'package:rakuraku_shusseki_app/view/event_creation_view/widget/time_text_field.dart';

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
    await showDatePickerDialog(
      context,
      (dateTime) {
        setState(() {
          _dateController.text =
              "${dateTime.year}/${dateTime.month}/${dateTime.day}";
        });
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    await showTimePickerDialog(
      context,
      (dateTime) {
        setState(() {
          final formattedTime =
              "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
          _timeController.text = formattedTime;
        });
      },
    );
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
            EventTitleTextField(controller: _eventTitleController),
            const SizedBox(height: 40),
            Center(
              child: Row(
                children: [
                  Expanded(
                    child: DateTextField(
                      controller: _dateController,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TimeTextField(
                      controller: _timeController,
                      onTap: () => _selectTime(context),
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
