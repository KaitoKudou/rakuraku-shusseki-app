import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_repository_provider.g.dart';

class IsarRepository {
  Future<Isar> openIsar() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [EventSchema],
      directory: dir.path,
    );
    return isar;
  }
}

@riverpod
IsarRepository isarRepository(IsarRepositoryRef ref) {
  return IsarRepository();
}
