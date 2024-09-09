import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/event_list_state_notifier.dart';
import 'package:rakuraku_shusseki_app/provider/route_observer_provider.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/attendee_list_view.dart';
import 'package:rakuraku_shusseki_app/view/event_creation_view.dart';

class EventListView extends ConsumerStatefulWidget {
  const EventListView({super.key});

  @override
  ConsumerState createState() => _EventListViewState();
}

class _EventListViewState extends ConsumerState<EventListView> with RouteAware {
  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    await ref.read(eventListStateNotifierProvider.notifier).initialize();
    await ref.read(eventListStateNotifierProvider.notifier).loadEventsData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteAwareを使用してRouteObserverを登録
    final routeObserver = ref.read(routeObserverProvider);
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    // 画面が再表示されたときにデータを再読み込み
    ref.read(eventListStateNotifierProvider.notifier).loadEventsData();
  }

  @override
  void dispose() {
    final routeObserver = ref.read(routeObserverProvider);
    routeObserver.unsubscribe(this);
    super.dispose();
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
                ref
                    .read(eventListStateNotifierProvider.notifier)
                    .deleteEvent(event: event);
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
    final events = ref.watch(eventListStateNotifierProvider); // イベントのリストを監視

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
                            isEventAddMode: false,
                            editingTargetEvent: event,
                          ),
                        );
                      },
                    ).then((isUpdated) async {
                      if (isUpdated ?? false) {
                        await ref
                            .read(eventListStateNotifierProvider.notifier)
                            .loadEventsData();
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
                          event: event,
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
                  child: const EventCreationView(
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
