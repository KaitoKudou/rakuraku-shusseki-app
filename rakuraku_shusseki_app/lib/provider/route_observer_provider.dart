import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_observer_provider.g.dart';

@riverpod
RouteObserver<PageRoute> routeObserver(RouteObserverRef ref) {
  return RouteObserver<PageRoute>();
}
