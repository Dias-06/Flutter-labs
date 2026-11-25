import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

class UserRepository {
  UserRepository(this._api, [UsersCache? cache])
      : _cache = cache ?? UsersCache();

  final ApiClient _api;
  final UsersCache _cache;

  Future<List<User>> _fetch() async {
    final data = await _api.get('/users');
    try {
      final list = data as List<dynamic>;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BadResponseException('users: $e');
    }
  }

  Future<({List<User> items, bool fromCache})> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<User> getById(int id) async {
    final data = await _api.get('/users/$id');
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final data = await _api.post('/users', draft.toJson());
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw BadResponseException('users/create: $e');
    }
  }
}