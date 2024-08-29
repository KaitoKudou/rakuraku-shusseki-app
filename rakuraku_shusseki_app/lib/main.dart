import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/provider/isar_provider.dart';
import 'package:rakuraku_shusseki_app/provider/route_observer_provider.dart';
import 'package:rakuraku_shusseki_app/view/event_list_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsyncValue = ref.watch(isarProvider);
    final routeObserver = ref.read(routeObserverProvider);

    return isarAsyncValue.when(
      data: (isar) {
        return MaterialApp(
          home: const EventListView(),
          navigatorObservers: [routeObserver],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }
}
