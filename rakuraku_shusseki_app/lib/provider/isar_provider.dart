import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/provider/isar_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_provider.g.dart';

@riverpod
Future<Isar> isar(IsarRef ref) async {
  final isarRepository = ref.watch(isarRepositoryProvider);
  return await isarRepository.openIsar();
}
