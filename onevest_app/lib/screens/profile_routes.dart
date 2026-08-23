import 'package:flutter/material.dart';
import 'settings_screen.dart';

class ProfileRoutes {
  static void openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}
