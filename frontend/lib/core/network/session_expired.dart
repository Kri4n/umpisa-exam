import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped by the HTTP layer whenever the API answers 401 on a protected call.
/// The auth feature listens to it and signs the user out.
class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state++;
}

final sessionExpiredProvider =
    NotifierProvider<SessionExpiredNotifier, int>(SessionExpiredNotifier.new);
