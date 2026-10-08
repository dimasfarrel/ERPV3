import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDark = prefs.getBool(_darkKey);
      final savedAccent = prefs.getInt(_accentKey);
      if (savedDark != null) provider.setThemeMode(savedDark);
      if (savedAccent != null) provider.setPrimaryColor(Color(savedAccent));

      var lastDark = provider.isDarkMode;
      var lastAccent = provider.primaryColor.toARGB32();
      provider.addListener(() {
        final dark = provider.isDarkMode;
        final accent = provider.primaryColor.toARGB32();
        if (dark != lastDark) {
          lastDark = dark;
          prefs.setBool(_darkKey, dark);
        }
        if (accent != lastAccent) {
          lastAccent = accent;
          prefs.setInt(_accentKey, accent);
        }
      });
    } catch (_) {
      // Gagal baca/tulis preferensi tidak boleh menghalangi aplikasi berjalan.
    }
  }
}
