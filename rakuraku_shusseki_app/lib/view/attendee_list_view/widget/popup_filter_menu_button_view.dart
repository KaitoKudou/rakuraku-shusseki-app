import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/model/event.dart';

class PopupFilterMenuButtonView extends StatefulWidget {
  final Status? selectedFilter;
  final Function(Status? selected) executeFilterAttendees;

  const PopupFilterMenuButtonView({
    required this.selectedFilter,
    required this.executeFilterAttendees,
    super.key,
  });

  @override
  State<PopupFilterMenuButtonView> createState() =>
      _PopupFilterMenuButtonView();
}

class _PopupFilterMenuButtonView extends State<PopupFilterMenuButtonView> {
  late Status? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  void _onSelected(Status filter) {
    setState(() {
      if (_selectedFilter == filter) {
        _selectedFilter = null; // 同じ選択肢を再度タップした場合、選択状態を解除する
      } else {
        _selectedFilter = filter;
      }
    });
    widget.executeFilterAttendees(_selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Status>(
      icon: const Icon(Icons.filter_list),
      onSelected: _onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Status>>[
        PopupMenuItem<Status>(
          value: Status.attending,
          child: Text(
            '出席',
            style: TextStyle(
              fontWeight: _selectedFilter == Status.attending
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _selectedFilter == Status.attending
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
              fontWeight: _selectedFilter == Status.absent
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _selectedFilter == Status.absent
                  ? Colors.green.shade600
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}
