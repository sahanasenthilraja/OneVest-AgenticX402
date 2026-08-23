import 'dart:async';

class AppLockService {
  static Timer? _timer;

  static const Duration timeout = Duration(minutes: 5);

  static bool _running = false;

  // ============================================================
  // START
  // ============================================================

  static void start({
    required void Function() onLocked,
  }) {
    // Always cancel the previous timer first.
    _timer?.cancel();
    _timer = null;

    _running = true;

    _timer = Timer(timeout, () {
      // The timer has fired, so clear the reference first.
      _timer = null;
      _running = false;

      // Execute the lock callback only once.
      onLocked();
    });
  }

  // ============================================================
  // RESET
  // ============================================================

  static void reset({
    required void Function() onLocked,
  }) {
    stop();

    start(
      onLocked: onLocked,
    );
  }

  // ============================================================
  // STOP
  // ============================================================

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  // ============================================================
  // STATUS
  // ============================================================

  static bool get isRunning => _running;
}
