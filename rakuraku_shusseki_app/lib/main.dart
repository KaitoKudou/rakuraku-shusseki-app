import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/view/event_list_view.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<Isar> openIsar() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [EventSchema],
    directory: dir.path,
  );
  return isar;
}

Future<void> main() async {
  final isar = await openIsar();
  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isar});
  final Isar isar;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventListView(isar: isar),
      navigatorObservers: [routeObserver],
    );
  }
}
