import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:isar/isar.dart';
import 'package:rakuraku_shusseki_app/main.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/attendee_list_view.dart';
import 'package:rakuraku_shusseki_app/view/event_creation_view.dart';

class EventListView extends StatefulWidget {
  const EventListView({super.key, required this.isar});
  final Isar isar;

  @override
  State<EventListView> createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView> with RouteAware {
  List<Event> events = [];

  @override
  void initState() {
    loadEventsData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteAwareを使用してRouteObserverを登録
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    // 画面が再表示されたときにデータを再読み込み
    loadEventsData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  //データベースのデータを取得
  Future<void> loadEventsData() async {
    final data = await widget.isar.events.where().findAll();
    setState(() {
      events = data;
    });
  }

  // データベースからイベントを削除
  Future<void> deleteEvent({required Event event}) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.events.delete(event.id);
    });

    await loadEventsData();
  }

  // イベント削除確認ダイアログ
  Future<void> showDeleteConfirmationDialog({required Event event}) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('イベントを削除しますか？'),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('削除'),
              onPressed: () {
                deleteEvent(event: event);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 画面のサイズを取得
    Size screenSize = MediaQuery.sizeOf(context);

    Widget emptyView() {
      return const Text('登録されたイベントがありません');
    }

    Widget eventListView() {
      return ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Slidable(
            key: ValueKey(events[index]),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      clipBehavior: Clip.none,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return Container(
                          color: Colors.black,
                          height: (screenSize.height * 0.7) +
                              MediaQuery.of(context).viewInsets.bottom,
                          child: EventCreationView(
                            isar: widget.isar,
                            isEventAddMode: false,
                            editingTargetEvent: event,
                          ),
                        );
                      },
                    ).then((isUpdated) async {
                      if (isUpdated ?? false) {
                        await loadEventsData();
                      }
                    });
                  },
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: '編集',
                ),
                SlidableAction(
                  onPressed: (_) {
                    showDeleteConfirmationDialog(event: event);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: '削除',
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(event.eventTitle),
                  subtitle: Text('${event.effectiveDate}  ${event.startTime}'),
                  onTap: () {
                    // 参加者一覧画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendeeListView(
                          eventId: event.id,
                          isar: widget.isar,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    color: Colors.grey.shade400,
                    thickness: 1,
                    height: 1,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'イベント一覧',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade600,
        ),
        body: Center(
          child: events.isEmpty ? emptyView() : eventListView(),
        ),
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          onPressed: () {
            // イベント追加画面に遷移
            debugPrint('イベント追加画面に遷移');

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              clipBehavior: Clip.none,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              builder: (BuildContext context) {
                return Container(
                  color: Colors.black,
                  height: (screenSize.height * 0.7) +
                      MediaQuery.of(context).viewInsets.bottom,
                  child: EventCreationView(
                    isar: widget.isar,
                    isEventAddMode: true,
                  ),
                );
              },
            );
          },
          foregroundColor: Colors.white,
          backgroundColor: Colors.green.shade600,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
