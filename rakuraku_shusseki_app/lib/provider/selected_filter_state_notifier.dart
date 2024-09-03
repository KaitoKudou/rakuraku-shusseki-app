import 'package:rakuraku_shusseki_app/model/event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_filter_state_notifier.g.dart';

@riverpod
class SelectedFilterStateNotifier extends _$SelectedFilterStateNotifier {
  @override
  Status? build() {
    return null;
  }

  void initialize({required Status? status}) {
    state = status;
  }

  void onSelected(Status? filter) {
    if (state == filter) {
      state = null; // 同じ選択肢を再度タップした場合、選択状態を解除する
    } else {
      state = filter;
    }
  }
}
