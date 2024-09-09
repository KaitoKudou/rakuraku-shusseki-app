import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';

class AttendeeRepository {
  final Isar isar;

  AttendeeRepository({required this.isar});

  // idと合致する参加者を取得
  Future<List<Attendee>?> loadEventData({required Id id}) async {
    final events = await isar.events.filter().idEqualTo(id).findFirst();
    return events?.attendee;
  }

  // 参加者をデータベースに追加
  Future<void> addAttendeeToEvent({
    required Event editingTargetEvent,
    required Attendee newAttendee,
  }) async {
    // attendeeリストを可変リストに変換
    final mutableAttendeeList =
        List<Attendee>.from(editingTargetEvent.attendee);
    mutableAttendeeList.insert(0, newAttendee);

    editingTargetEvent.attendee = mutableAttendeeList;

    await isar.writeTxn(
      () async {
        await isar.events.put(editingTargetEvent);
      },
    );
  }

  // 参加者の氏名を変更しデータベースを更新
  Future<void> changeAttendeeName({
    required Event editingTargetEvent,
    required String previousName,
    required String newName,
  }) async {
    final index = editingTargetEvent.attendee
        .indexWhere((attendee) => attendee.name == previousName);

    // indexWhereはマッチしなければ -1 を返す
    if (index != -1) {
      editingTargetEvent.attendee[index].name = newName;

      await isar.writeTxn(() async {
        await isar.events.put(editingTargetEvent);
      });
    }
  }

  // 出欠状況を変更
  Future<void> updateAttendeeStatus({
    required Event editingTargetEvent,
    required Attendee targetAttendee,
    required Status newStatus,
  }) async {
    final index = editingTargetEvent.attendee
        .indexWhere((attendee) => attendee.name == targetAttendee.name);

    // indexWhereはマッチしなければ -1 を返す
    if (index != -1) {
      editingTargetEvent.attendee[index].status = newStatus;

      await isar.writeTxn(() async {
        await isar.events.put(editingTargetEvent);
      });
    }
  }
}
