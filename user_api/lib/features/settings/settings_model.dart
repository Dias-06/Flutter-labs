import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
      this._prefs, {
        required bool dark,
        String? city,
        String? avatarPath,
      })  : _dark = dark,
        _city = city,
        _avatarPath = avatarPath;

  final SharedPreferencesAsync _prefs;

  bool _dark;
  String? _city;
  String? _avatarPath;

  bool get dark => _dark;
  String? get city => _city;
  String? get avatarPath => _avatarPath;

  void setDark(bool v) {
    _dark = v;
    notifyListeners(); // Сначала обновляем UI, не ждем диск!
    unawaited(_prefs.setBool('darkMode', v));
  }

  void setCity(String? c) {
    _city = c;
    notifyListeners();
    if (c == null) {
      unawaited(_prefs.remove('cityFilter'));
    } else {
      unawaited(_prefs.setString('cityFilter', c));
    }
  }

  void setAvatarPath(String? path) {
    _avatarPath = path;
    notifyListeners();
    if (path == null) {
      unawaited(_prefs.remove('avatarPath'));
    } else {
      unawaited(_prefs.setString('avatarPath', path));
    }
  }
}