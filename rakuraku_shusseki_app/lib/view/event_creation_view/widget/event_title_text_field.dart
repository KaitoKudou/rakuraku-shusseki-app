import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventTitleTextField extends StatelessWidget {
  final TextEditingController controller;

  const EventTitleTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const placeholder = 'イベント名を入力';

    return Platform.isIOS
        ? CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          )
        : TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          );
  }
}
