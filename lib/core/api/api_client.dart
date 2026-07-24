import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_config.dart';

/// HTTP client for RVIOS NestJS API.
///
/// Automatically attaches Supabase JWT and company context to every request.
/// Handles errors, timeouts, and JSON parsing uniformly.
class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // ── Build headers ──────────────────────────────────
  Map<String, String> _headers({String? companyId}) {
    final session = Supabase.instance.client.auth.currentSession;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (session != null) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    if (companyId != null && companyId.isNotEmpty) {
      headers['x-company-id'] = companyId;
    }

    return headers;
  }

  // ── GET ────────────────────────────────────────────
  Future<dynamic> get(
    String endpoint, {
    String? companyId,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await _httpClient
          .get(uri, headers: _headers(companyId: companyId))
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت', isNetworkError: true);
    } on TimeoutException {
      throw ApiException('انتهت مدة الاتصال — تحقق من اتصالك', isTimeout: true);
    }
  }

  // ── POST ───────────────────────────────────────────
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? companyId,
  }) async {
    final uri = _buildUri(endpoint, null);
    try {
      final response = await _httpClient
          .post(uri, headers: _headers(companyId: companyId), body: jsonEncode(body))
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت', isNetworkError: true);
    } on TimeoutException {
      throw ApiException('انتهت مدة الاتصال', isTimeout: true);
    }
  }

  // ── PATCH ──────────────────────────────────────────
  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body, {
    String? companyId,
  }) async {
    final uri = _buildUri(endpoint, null);
    try {
      final response = await _httpClient
          .patch(uri, headers: _headers(companyId: companyId), body: jsonEncode(body))
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت', isNetworkError: true);
    } on TimeoutException {
      throw ApiException('انتهت مدة الاتصال', isTimeout: true);
    }
  }

  // ── DELETE ─────────────────────────────────────────
  Future<void> delete(String endpoint, {String? companyId}) async {
    final uri = _buildUri(endpoint, null);
    try {
      final response = await _httpClient
          .delete(uri, headers: _headers(companyId: companyId))
          .timeout(ApiConfig.timeout);
      if (response.statusCode != 204 && response.statusCode >= 400) {
        _handleResponse(response);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت', isNetworkError: true);
    } on TimeoutException {
      throw ApiException('انتهت مدة الاتصال', isTimeout: true);
    }
  }

  // ── Response handler ───────────────────────────────
  dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint('[API] ${response.request?.method} ${response.request?.url} → ${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty || response.statusCode == 204) return null;
      return jsonDecode(response.body);
    }

    String message = 'حدث خطأ غير متوقع';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message']?.toString() ?? message;
    } catch (_) {}

    switch (response.statusCode) {
      case 401:
        throw ApiException('غير مصرح — يرجى تسجيل الدخول مجدداً', statusCode: 401);
      case 403:
        throw ApiException('ليس لديك صلاحية لهذه العملية', statusCode: 403);
      case 404:
        throw ApiException('العنصر غير موجود', statusCode: 404);
      case 409:
        throw ApiException(message, statusCode: 409);
      case 429:
        throw ApiException('طلبات كثيرة — حاول بعد قليل', statusCode: 429);
      default:
        throw ApiException(message, statusCode: response.statusCode);
    }
  }

  // ── URI builder ────────────────────────────────────
  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final base = Uri.parse('${ApiConfig.apiUrl}$endpoint');
    if (queryParams == null || queryParams.isEmpty) return base;
    return base.replace(queryParameters: {
      ...base.queryParameters,
      ...queryParams.map((k, v) => MapEntry(k, v)),
    });
  }

  void dispose() => _httpClient.close();
}

/// API Exception with metadata for proper error handling in UI.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final bool isTimeout;

  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
    this.isTimeout = false,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isOffline => isNetworkError || isTimeout;

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}