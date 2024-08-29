import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rakuraku_shusseki_app/provider/member_button_enabled_notifier.dart';

class AttendeeNameChangeDialog extends ConsumerStatefulWidget {
  final String previousName;
  final Future<void> Function(String newName) updateAttendeeToEvent;

  const AttendeeNameChangeDialog({
    super.key,
    required this.previousName,
    required this.updateAttendeeToEvent,
  });

  @override
  ConsumerState createState() => _AttendeeNameChangeDialogState();
}

class _AttendeeNameChangeDialogState
    extends ConsumerState<AttendeeNameChangeDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.previousName;

    _controller.addListener(() {
      ref
          .watch(memberButtonEnabledNotifierProvider.notifier)
          .updateButtonEnable(isOn: _controller.text.isNotEmpty);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String title = '名前を変更';
    const String message = '変更したい名前を入力してください。';
    final isButtonEnabled = ref.watch(memberButtonEnabledNotifierProvider);

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
        TextButton(
          onPressed: isButtonEnabled
              ? () async {
                  await widget.updateAttendeeToEvent(_controller.text);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('変更'),
        ),
      ],
    );
  }
}
