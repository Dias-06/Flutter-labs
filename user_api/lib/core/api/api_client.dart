import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/secure_store.dart';
import 'api_exception.dart';

typedef Headers = Map<String, String>;

class ApiClient {
  ApiClient(
      this._client,
      this._store, {
        this.host = 'jsonplaceholder.typicode.com',
      });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<Headers> _headers([Headers? extra]) async {
    return {
      'Accept': 'application/json',
      if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
      ...?extra,
    };
  }

  Future<dynamic> get(String path, [Headers? query]) async {
    final uri = Uri.https(host, path, query);
    final headers = await _headers();
    final response = await _send(() => _client.get(uri, headers: headers));
    _check(response);
    return _decode(response);
  }

  Future<dynamic> post(String path, Object body) async {
    final uri = Uri.https(host, path);
    final headers = await _headers({'Content-Type': 'application/json'});
    final response = await _send(
          () => _client.post(uri, headers: headers, body: jsonEncode(body)),
    );
    _check(response);
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      assert(() {
        dev.log(
          '${response.request?.method} ${response.request?.url} -> ${response.statusCode}',
          name: 'api',
        );
        return true;
      }());
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    if (r.statusCode == 401) throw const UnauthorizedException();
    if (r.statusCode == 404) throw const NotFoundException();
    if (r.statusCode >= 500) throw ServerException(r.statusCode);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw BadResponseException('Unexpected status: ${r.statusCode}');
    }
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('Invalid JSON: ${e.message}');
    }
  }
}