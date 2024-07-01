import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/view/event_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EventListView(),
    );
  }
}
