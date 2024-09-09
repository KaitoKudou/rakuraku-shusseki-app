import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:rakuraku_shusseki_app/provider/selected_filter_state_notifier.dart';

class PopupFilterMenuButtonView extends ConsumerStatefulWidget {
  final Future<void> Function() executeFilterAttendees;

  const PopupFilterMenuButtonView({
    required this.executeFilterAttendees,
    super.key,
  });

  @override
  ConsumerState createState() => _PopupFilterMenuButtonView();
}

class _PopupFilterMenuButtonView
    extends ConsumerState<PopupFilterMenuButtonView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initStatus = ref.read(selectedFilterStateNotifierProvider);
      ref
          .read(selectedFilterStateNotifierProvider.notifier)
          .initialize(status: initStatus);
    });
    super.initState();
  }

  void _onSelected(Status filter) {
    ref.read(selectedFilterStateNotifierProvider.notifier).onSelected(filter);
    widget.executeFilterAttendees();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStatus = ref.watch(selectedFilterStateNotifierProvider);
    return PopupMenuButton<Status>(
      icon: const Icon(Icons.filter_list),
      onSelected: _onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Status>>[
        PopupMenuItem<Status>(
          value: Status.attending,
          child: Text(
            '出席',
            style: TextStyle(
              fontWeight: selectedStatus == Status.attending
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: selectedStatus == Status.attending
                  ? Colors.green.shade600
                  : Colors.grey.shade400,
            ),
          ),
        ),
        PopupMenuItem<Status>(
          value: Status.absent,
          child: Text(
            '欠席',
            style: TextStyle(
              fontWeight: selectedStatus == Status.absent
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: selectedStatus == Status.absent
                  ? Colors.green.shade600
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}
