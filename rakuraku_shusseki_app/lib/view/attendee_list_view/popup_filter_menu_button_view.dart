import 'package:flutter/material.dart';
import 'package:rakuraku_shusseki_app/view/attendee_list_view/filter_options.dart';

class PopupFilterMenuButtonView extends StatefulWidget {
  final FilterOptions? selectedFilter;
  final ValueChanged<FilterOptions?> onSelected;

  const PopupFilterMenuButtonView({
    required this.selectedFilter,
    required this.onSelected,
    super.key,
  });

  @override
  State<PopupFilterMenuButtonView> createState() =>
      _PopupFilterMenuButtonView();
}

class _PopupFilterMenuButtonView extends State<PopupFilterMenuButtonView> {
  late FilterOptions? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  void _onFilterSelected(FilterOptions filter) {
    setState(() {
      if (_selectedFilter == filter) {
        _selectedFilter = null; // 同じ選択肢を再度タップした場合、選択状態を解除する
      } else {
        _selectedFilter = filter;
      }
    });
    widget.onSelected(_selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterOptions>(
      icon: const Icon(Icons.filter_list),
      onSelected: _onFilterSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterOptions>>[
        PopupMenuItem<FilterOptions>(
          value: FilterOptions.attending,
          child: Text(
            '出席',
            style: TextStyle(
              fontWeight: _selectedFilter == FilterOptions.attending
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _selectedFilter == FilterOptions.attending
                  ? Colors.green.shade600
                  : Colors.grey.shade400,
            ),
          ),
        ),
        PopupMenuItem<FilterOptions>(
          value: FilterOptions.absent,
          child: Text(
            '欠席',
            style: TextStyle(
              fontWeight: _selectedFilter == FilterOptions.absent
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _selectedFilter == FilterOptions.absent
                  ? Colors.green.shade600
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}
