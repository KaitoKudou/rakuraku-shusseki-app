import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/view/event_creation_view/widget/date_text_field.dart';

class TimeTextField extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function() onTap;

  const TimeTextField({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const placeholder = '開始時刻を入力';

    return Platform.isIOS
        ? CupertinoTextField(
            controller: controller,
            focusNode: AlwaysDisabledFocusNode(),
            placeholder: placeholder,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),
            onTap: () {
              onTap();
            },
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          )
        : TextField(
            controller: controller,
            focusNode: AlwaysDisabledFocusNode(),
            decoration: InputDecoration(
              labelText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
            ),
            readOnly: true,
            onTap: () {
              onTap();
            },
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          );
  }
}
