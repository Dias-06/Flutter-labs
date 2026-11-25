import 'package:flutter/foundation.dart';
import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {String? initialToken}) : _token = initialToken;

  final SecureStore _store;
  String? _token;
  bool _loading = false;

  bool get signedIn => _token != null && _token!.isNotEmpty;
  bool get loading => _loading;

  Future<void> login(String email, String password) async {
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }
    _loading = true;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final token = 'tok_${email.hashCode}';
      await _store.saveToken(token);
      _token = token;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}