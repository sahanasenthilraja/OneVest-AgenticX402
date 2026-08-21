import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _pinKey = 'onevest_transaction_pin';

  static Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  static Future<void> savePin(String pin) async {
    await _storage.write(
      key: _pinKey,
      value: pin,
    );
  }

  static Future<bool> verifyPin(String pin) async {
    final savedPin = await _storage.read(
      key: _pinKey,
    );

    return savedPin != null && savedPin == pin;
  }

  static Future<void> clearPin() async {
    await _storage.delete(
      key: _pinKey,
    );
  }
}