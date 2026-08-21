import 'dart:async';

class AppLockService {
  static Timer? _timer;

  static const Duration timeout = Duration(minutes: 5);

  static void start({
    required void Function() onLocked,
  }) {
    _timer?.cancel();

    _timer = Timer(timeout, onLocked);
  }

  static void reset({
    required void Function() onLocked,
  }) {
    start(onLocked: onLocked);
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}