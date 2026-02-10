import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../state/session.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _envOverride() ?? _defaultBaseUrl();

  static String _defaultBaseUrl() {
    // Use localhost for web/desktop, 10.0.2.2 for Android emulator.
    if (kIsWeb) return 'http://localhost:4000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:4000/api';
    return 'http://localhost:4000/api';
  }

  static String? _envOverride() {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    return null;
  }

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _throwIfError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> delete(String path) async {
    final res = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    _throwIfError(res);
  }

  Future<List<dynamic>> getList(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final res = await _client.get(uri, headers: _headers());
    _throwIfError(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = Session.token;
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  void _throwIfError(http.Response res) {
    if (res.statusCode >= 400) {
      if (res.statusCode == 401) throw UnauthorizedException();
      String message = 'API error ${res.statusCode}';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}

class UnauthorizedException implements Exception {}
