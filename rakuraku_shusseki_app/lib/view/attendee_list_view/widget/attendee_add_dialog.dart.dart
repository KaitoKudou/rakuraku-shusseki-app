import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';

class AttendeeAddDialog extends StatefulWidget {
  final Future<void> Function(Attendee newAttendee) addAttendeeToEvent;

  const AttendeeAddDialog({
    super.key,
    required this.addAttendeeToEvent,
  });

  @override
  State<AttendeeAddDialog> createState() => _AttendeeAddDialogState();
}

class _AttendeeAddDialogState extends State<AttendeeAddDialog> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isAddMemberButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    _controller.addListener(() {
      _isAddMemberButtonEnabled.value = _controller.text.isNotEmpty;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _isAddMemberButtonEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'メンバー追加';
    const String message = '追加したい人の名前を入力してください。';

    return AlertDialog(
      title: const Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(message),
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
                      Attendee newAttendee = Attendee()
                        ..name = _controller.text
                        ..status = Status.attending;
                      await widget.addAttendeeToEvent(newAttendee);
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
  }
}
