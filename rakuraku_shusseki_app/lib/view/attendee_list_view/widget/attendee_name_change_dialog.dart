import 'package:flutter/material.dart';

class AttendeeNameChangeDialog extends StatefulWidget {
  final String previousName;
  final Future<void> Function(String newName) updateAttendeeToEvent;

  const AttendeeNameChangeDialog({
    super.key,
    required this.previousName,
    required this.updateAttendeeToEvent,
  });

  @override
  State<AttendeeNameChangeDialog> createState() =>
      _AttendeeNameChangeDialogState();
}

class _AttendeeNameChangeDialogState extends State<AttendeeNameChangeDialog> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isAddMemberButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    _controller.text = widget.previousName;

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
    const String title = '名前を変更';
    const String message = '変更したい名前を入力してください。';

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
                      await widget.updateAttendeeToEvent(_controller.text);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('変更'),
            );
          },
        ),
      ],
    );
  }
}
