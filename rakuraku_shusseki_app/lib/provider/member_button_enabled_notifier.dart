import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_button_enabled_notifier.g.dart';

@riverpod
class MemberButtonEnabledNotifier extends _$MemberButtonEnabledNotifier {
  @override
  bool build() {
    return false;
  }

  void updateButtonEnable({required bool isOn}) {
    state = isOn;
  }
}
