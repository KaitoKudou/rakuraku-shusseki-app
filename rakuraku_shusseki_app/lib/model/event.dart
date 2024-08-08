import 'package:isar/isar.dart';

part 'event.g.dart';

@collection
class Event {
  Id id = Isar.autoIncrement;
  String? eventTitle;
  String? effectiveDate;
  String? startTime;
  List<Attendee> attendee = [];
}

@embedded
class Attendee {
  late String name;

  @enumerated
  late Status status;
}

enum Status {
  attending,
  absent,
}
