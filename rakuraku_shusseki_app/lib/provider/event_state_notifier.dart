import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/isar_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_state_notifier.g.dart';

@riverpod
class EventStateNotifier extends _$EventStateNotifier {
  @override
  List<Event> build() {
    return [];
  }

  //データベースのデータを取得
  Future<void> loadEventsData() async {
    final isar = await ref.read(isarProvider.future);
    final data = await isar.events.where().findAll();
    state = data;
  }

  // データベースからイベントを削除
  Future<void> deleteEvent({required Event event}) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.events.delete(event.id);
    });

    await loadEventsData();
  }
}
