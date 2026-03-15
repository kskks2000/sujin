import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tms_mobile/models/company_option.dart';
import 'package:tms_mobile/models/dashboard_summary.dart';
import 'package:tms_mobile/models/dispatch_item.dart';
import 'package:tms_mobile/models/order_create_request.dart';
import 'package:tms_mobile/models/order_item.dart';
import 'package:tms_mobile/models/session.dart';

class TmsApiClient {
  TmsApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  static const _requestTimeout = Duration(seconds: 30);

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
        .timeout(_requestTimeout);

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

  Future<List<CompanyOption>> fetchCompanies() async {
    final response = await _get('/companies');
    return _asList(response.body).map(CompanyOption.fromJson).toList();
  }

  Future<void> createOrder(OrderCreateRequest payload) async {
    final response = await _post('/orders', payload.toJson());

    if (response.statusCode != 201) {
      throw Exception('Order create failed (${response.statusCode})');
    }
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
        .timeout(_requestTimeout);
  }

  Future<http.Response> _post(String path, Map<String, dynamic> payload) {
    return _httpClient
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_token != null) 'Authorization': 'Bearer $_token',
          },
          body: jsonEncode(payload),
        )
        .timeout(_requestTimeout);
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
      final current = Uri.base;
      final currentHost = current.host;
      final isCurrentHostRemote =
          currentHost.isNotEmpty && currentHost != 'localhost' && currentHost != '127.0.0.1';
      final isLocalTarget = parsed.host == 'localhost' || parsed.host == '127.0.0.1';
      final isCurrentHostTarget = parsed.host == currentHost;

      if (isCurrentHostRemote && (isLocalTarget || isCurrentHostTarget)) {
        normalized = Uri.parse('${current.origin}/api/v1');
      }
    }

    final text = normalized.toString();
    return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
  }
}
