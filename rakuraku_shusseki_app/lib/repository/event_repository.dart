import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';

class EventRepository {
  final Isar isar;

  EventRepository({required this.isar});

  Future<Event> createEvent({
    required String title,
    required String date,
    required String time,
  }) async {
    final Event event = Event()
      ..eventTitle = title
      ..effectiveDate = date
      ..startTime = time;

    await isar.writeTxn(() async {
      await isar.events.put(event);
    });

    return event;
  }

  Future<void> editEvent({
    required Event event,
    required String title,
    required String date,
    required String time,
  }) async {
    event
      ..eventTitle = title
      ..effectiveDate = date
      ..startTime = time;

    await isar.writeTxn(() async {
      await isar.events.put(event);
    });
  }

  Future<void> deleteEvent({required Event event}) async {
    await isar.writeTxn(() async {
      await isar.events.delete(event.id);
    });
  }

  Future<List<Event>> loadEventsData() async {
    return await isar.events.where().findAll();
  }

  Future<Event?> loadEventById(int id) async {
    return await isar.events.get(id);
  }
}
