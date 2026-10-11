import 'package:flutter/material.dart';
// SharedPreferences removed; UI settings persisted via server API.
import '../../data/providers/app_provider.dart';

/// Menyimpan preferensi tampilan (mode gelap & warna aksen) ke penyimpanan lokal.
///
/// Sengaja dipisah dari [AppProvider] dan memakai key sendiri (`ui_*`) supaya
/// tidak bersinggungan dengan penyimpanan token/kredensial/koneksi database.
class ThemePersistence {
  static const _darkKey = 'ui_dark_mode';
  static const _accentKey = 'ui_accent_color';

  /// Pulihkan preferensi tersimpan ke [provider], lalu pantau perubahannya.
  static Future<void> restoreAndWatch(AppProvider provider) async {
    // Load UI settings from server
    await provider.loadUiSettings();
    // Watch for changes and persist to server
    provider.addListener(() async {
      await provider.saveUiSettings();
    });
  }
}
