import 'package:isar/isar.dart';

part 'event.g.dart';

@collection
class Event {
  Id id = Isar.autoIncrement;
  late String eventTitle;
  late String effectiveDate;
  late String startTime;
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
