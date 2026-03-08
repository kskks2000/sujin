import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tms_mobile/models/dashboard_summary.dart';
import 'package:tms_mobile/models/dispatch_item.dart';
import 'package:tms_mobile/models/order_item.dart';
import 'package:tms_mobile/models/session.dart';

class TmsApiClient {
  TmsApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  String _baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
  String? _token;

  void configure({required String baseUrl, String? token}) {
    _baseUrl = _normalizeBaseUrl(baseUrl);
    _token = token;
  }

  Future<Session> login({
    required String baseUrl,
    required String loginId,
    required String password,
  }) async {
    final resolvedBaseUrl = _normalizeBaseUrl(baseUrl);
    final response = await _httpClient
        .post(
          Uri.parse('$resolvedBaseUrl/auth/login'),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'login_id': loginId, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final session = Session.fromJson(body, resolvedBaseUrl);
    configure(baseUrl: resolvedBaseUrl, token: session.token);
    return session;
  }

  Future<DashboardSummary> fetchDashboardSummary() async {
    final response = await _get('/dashboard/summary');
    return DashboardSummary.fromJson(_asMap(response.body));
  }

  Future<List<OrderItem>> fetchOrders() async {
    final response = await _get('/orders');
    return _asList(response.body).map(OrderItem.fromJson).toList();
  }

  Future<List<DispatchItem>> fetchDispatches() async {
    final response = await _get('/dispatches');
    return _asList(response.body).map(DispatchItem.fromJson).toList();
  }

  Future<http.Response> _get(String path) {
    return _httpClient
        .get(
          Uri.parse('$_baseUrl$path'),
          headers: {
            'Accept': 'application/json',
            if (_token != null) 'Authorization': 'Bearer $_token',
          },
        )
        .timeout(const Duration(seconds: 10));
  }

  Map<String, dynamic> _asMap(String rawBody) {
    return jsonDecode(rawBody) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _asList(String rawBody) {
    final decoded = jsonDecode(rawBody) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  String _normalizeBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) {
      return trimmed;
    }

    var normalized = parsed;
    if (kIsWeb) {
      final currentHost = Uri.base.host;
      final isCurrentHostRemote =
          currentHost.isNotEmpty && currentHost != 'localhost' && currentHost != '127.0.0.1';
      final isLocalTarget = parsed.host == 'localhost' || parsed.host == '127.0.0.1';

      if (isCurrentHostRemote && isLocalTarget) {
        normalized = normalized.replace(
          scheme: Uri.base.scheme == 'https' ? 'https' : 'http',
          host: currentHost,
          port: parsed.hasPort ? parsed.port : 8000,
        );
      }
    }

    final text = normalized.toString();
    return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
  }
}
