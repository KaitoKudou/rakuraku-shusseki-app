import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/member_button_enabled_notifier.dart';

class AttendeeAddDialog extends ConsumerStatefulWidget {
  final Future<void> Function(Attendee newAttendee) addAttendeeToEvent;

  const AttendeeAddDialog({
    super.key,
    required this.addAttendeeToEvent,
  });

  @override
  ConsumerState createState() => _AttendeeAddDialogState();
}

class _AttendeeAddDialogState extends ConsumerState<AttendeeAddDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
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
    const String title = 'メンバー追加';
    const String message = '追加したい人の名前を入力してください。';
    const String add = '追加';
    const String cancel = 'キャンセル';
    final isButtonEnabled = ref.watch(memberButtonEnabledNotifierProvider);

    Future<void> addAction() async {
      Attendee newAttendee = Attendee()
        ..name = _controller.text
        ..status = Status.attending;
      await widget.addAttendeeToEvent(newAttendee);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }

    void cancelAction() {
      _controller.text = '';
      Navigator.pop(context);
    }

    final dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(message),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: _controller,
        ),
      ],
    );

    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: const Text(title),
            content: dialogContent,
            actions: [
              CupertinoDialogAction(
                onPressed: () => cancelAction(),
                child: const Text(cancel),
              ),
              CupertinoDialogAction(
                onPressed: isButtonEnabled
                    ? () async {
                        await addAction();
                      }
                    : null,
                child: const Text(add),
              ),
            ],
          )
        : AlertDialog(
            title: const Text(title),
            content: dialogContent,
            actions: [
              TextButton(
                child: const Text(cancel),
                onPressed: () => cancelAction(),
              ),
              TextButton(
                onPressed: isButtonEnabled
                    ? () async {
                        await addAction();
                      }
                    : null,
                child: const Text(add),
              ),
            ],
          );
  }
}
