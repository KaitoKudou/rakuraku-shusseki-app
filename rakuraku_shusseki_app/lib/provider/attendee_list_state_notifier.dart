import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/isar_provider.dart';
import 'package:rakuraku_shusseki_app/provider/selected_filter_state_notifier.dart';
import 'package:rakuraku_shusseki_app/repository/attendee_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendee_list_state_notifier.g.dart';

@riverpod
class AttendeeListStateNotifier extends _$AttendeeListStateNotifier {
  late final AttendeeRepository _repository;
  late final Id _id;

  @override
  List<Attendee> build() {
    return [];
  }

  Future<void> initialize({required Id id}) async {
    final isar = await ref.read(isarProvider.future);
    _repository = AttendeeRepository(isar: isar);
    _id = id;
  }

  // idと合致する参加者を取得
  Future<List<Attendee>?> loadAttendeesData() async {
    final data = await _repository.loadEventData(id: _id);
    if (data != null) {
      state = data;
    }
    return null;
  }

  // 指定された条件で参加者を絞り込み
  Future<void> filterAttendeesByEvent({required Event event}) async {
    final selectedStatus = ref.read(selectedFilterStateNotifierProvider);

    if (selectedStatus != null) {
      final filteredAttendees = event.attendee
          .where(
            (attendee) => attendee.status == selectedStatus,
          )
          .toList();
      state = filteredAttendees;
      return;
    }

    final allAttendees = await loadAttendeesData();
    if (allAttendees != null) {
      state = allAttendees;
    }
  }

  // 参加者をデータベースに追加
  Future<void> addAttendeeToEvent({
    required Event editingTargetEvent,
    required Attendee newAttendee,
  }) async {
    await _repository.addAttendeeToEvent(
      editingTargetEvent: editingTargetEvent,
      newAttendee: newAttendee,
    );

    final data = await loadAttendeesData();
    if (data != null) {
      state = data;
    }
  }

  // 参加者の氏名を変更しデータベースを更新
  Future<void> changeAttendeeName({
    required Event editingTargetEvent,
    required String previousName,
    required String newName,
  }) async {
    await _repository.changeAttendeeName(
      editingTargetEvent: editingTargetEvent,
      previousName: previousName,
      newName: newName,
    );

    final data = await loadAttendeesData();
    if (data != null) {
      state = data;
    }
  }

  // 出欠状況を変更
  Future<void> updateAttendeeStatus({
    required Event editingTargetEvent,
    required Attendee targetAttendee,
    required Status newStatus,
  }) async {
    Future<void> updateStatus() async {
      await _repository.updateAttendeeStatus(
        editingTargetEvent: editingTargetEvent,
        targetAttendee: targetAttendee,
        newStatus: newStatus,
      );
    }

    final selectedFilter = ref.read(selectedFilterStateNotifierProvider);
    if (selectedFilter != null) {
      final index = state.indexOf(targetAttendee);
      state[index].status = newStatus;
      state = List.from(state);

      // フィルターがある場合はstateを更新した後でDBの更新を最後に行う
      await updateStatus();

      return;
    }

    // フィルターが無い場合はDBの更新を最初に行う
    await updateStatus();
    final data = await loadAttendeesData();
    if (data != null) {
      state = data;
    }
  }
}
