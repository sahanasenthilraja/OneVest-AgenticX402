import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static String _pinKey(String uid) =>
      'onevest_transaction_pin_$uid';

  static Future<bool> hasPin(String uid) async {
    final pin = await _storage.read(
      key: _pinKey(uid),
    );

    return pin != null && pin.isNotEmpty;
  }

  static Future<void> savePin(
    String uid,
    String pin,
  ) async {
    await _storage.write(
      key: _pinKey(uid),
      value: pin,
    );
  }

  static Future<bool> verifyPin(
    String uid,
    String pin,
  ) async {
    final savedPin = await _storage.read(
      key: _pinKey(uid),
    );

    return savedPin != null && savedPin == pin;
  }

  static Future<void> clearPin(String uid) async {
    await _storage.delete(
      key: _pinKey(uid),
    );
  }
}
