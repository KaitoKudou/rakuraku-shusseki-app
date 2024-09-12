import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showDatePickerDialog(
  BuildContext context,
  Function(DateTime) onDateTimeChanged,
) async {
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
              onDateTimeChanged(dateTime);
            },
          ),
        );
      },
    );
  } else {
    final DateTime? dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (dateTime != null) {
      onDateTimeChanged(dateTime);
    }
  }
}

Future<void> showTimePickerDialog(
  BuildContext context,
  Function(DateTime) onDateTimeChanged,
) async {
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
              onDateTimeChanged(dateTime);
            },
          ),
        );
      },
    );
  } else {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (timeOfDay != null) {
      DateTime dateTime = DateTime(timeOfDay.hour, timeOfDay.minute);
      onDateTimeChanged(dateTime);
    }
  }
}
