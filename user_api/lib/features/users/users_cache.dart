import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> list) async {
    final file = await _file();
    final jsonStr = jsonEncode([for (final u in list) u.toJson()]);
    await file.writeAsString(jsonStr);
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}