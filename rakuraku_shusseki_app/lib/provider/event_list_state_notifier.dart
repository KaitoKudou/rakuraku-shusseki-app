import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/isar_provider.dart';
import 'package:rakuraku_shusseki_app/repository/event_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_list_state_notifier.g.dart';

@riverpod
class EventListStateNotifier extends _$EventListStateNotifier {
  late EventRepository _eventRepository;

  @override
  List<Event> build() {
    return [];
  }

  Future<void> initialize() async {
    final isar = await ref.read(isarProvider.future);
    _eventRepository = EventRepository(isar: isar);
  }

  //データベースのデータを取得
  Future<void> loadEventsData() async {
    final data = await _eventRepository.loadEventsData();
    state = data;
  }

  // データベースからイベントを削除
  Future<void> deleteEvent({required Event event}) async {
    await _eventRepository.deleteEvent(event: event);
    await loadEventsData();
  }

  // イベントを新規作成して、データベースに保存
  Future<Event> createEvent({
    required String title,
    required String date,
    required String time,
  }) async {
    return await _eventRepository.createEvent(
      title: title,
      date: date,
      time: time,
    );
  }

  // 既存のイベントを編集して、データベースに保存
  Future<void> editEvent({
    required Event event,
    required String title,
    required String date,
    required String time,
  }) async {
    await _eventRepository.editEvent(
      event: event,
      title: title,
      date: date,
      time: time,
    );
  }
}
