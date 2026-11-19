import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get defaultHeaders => const {
    'Accept': 'application/json',
  };

  Future<dynamic> get(String path, [Map<String, String>? query]) async {
    final uri = Uri.https(host, path, query);
    final response = await _send(() => _client.get(uri, headers: defaultHeaders));
    _check(response);
    return _decode(response);
  }

  Future<dynamic> post(String path, Object body) async {
    final uri = Uri.https(host, path);
    final headers = {
      ...defaultHeaders,
      'Content-Type': 'application/json',
    };
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