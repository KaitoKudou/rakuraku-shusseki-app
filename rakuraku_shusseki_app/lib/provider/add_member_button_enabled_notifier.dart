import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_member_button_enabled_notifier.g.dart';

@riverpod
class AddMemberButtonEnabledNotifier extends _$AddMemberButtonEnabledNotifier {
  @override
  bool build() {
    return false;
  }

  void updateButtonEnable({required bool isOn}) {
    state = isOn;
  }
}
