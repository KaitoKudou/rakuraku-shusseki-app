import 'dart:io';

import 'package:flutter/cupertino.dart';
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
    const String change = '変更';
    const String cancel = 'キャンセル';
    final isButtonEnabled = ref.watch(memberButtonEnabledNotifierProvider);

    Future<void> changeAction() async {
      await widget.updateAttendeeToEvent(_controller.text);
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
        Platform.isIOS
            ? CupertinoTextField(controller: _controller)
            : TextField(controller: _controller),
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
                        await changeAction();
                      }
                    : null,
                child: const Text(change),
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
                        await changeAction();
                      }
                    : null,
                child: const Text(change),
              ),
            ],
          );
  }
}
