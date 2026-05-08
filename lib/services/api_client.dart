import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:PantryPal/utils/exceptions.dart';
import 'package:PantryPal/utils/token_manager.dart';

/// 底层 HTTP 客户端封装（单例）
///
/// 职责：BaseURL 管理、Token 注入、统一响应解析、错误处理
class ApiClient {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  ApiClient._() {
    // 生产环境强制 HTTPS
    assert(
      kDebugMode || baseUrl.startsWith('https://'),
      'Production API must use HTTPS',
    );
  }

  final _client = http.Client();
  static const _timeout = Duration(seconds: 30);

  /// 构建请求头（自动注入 Token）
  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await TokenManager.instance.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 处理响应，统一错误处理
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> body;
    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(response.statusCode, '服务器返回了无效的数据');
    }

    if (response.statusCode == 401) {
      // 不在 HTTP 层清 Token，让上层 catch UnauthorizedException 处理
      final detail = body['detail'] ?? '登录已过期，请重新登录';
      throw UnauthorizedException(detail.toString());
    }

    if (response.statusCode >= 400) {
      final detail = body['detail'];
      String message;
      if (detail is List && detail.isNotEmpty) {
        final first = detail[0];
        message =
            (first is Map ? first['msg'] : detail.toString()) ?? '请求参数错误';
      } else if (detail is String) {
        message = detail;
      } else {
        message = body['message']?.toString() ?? '请求失败';
      }
      throw ApiException(response.statusCode, message);
    }

    return body;
  }

  /// GET 请求
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters: queryParams,
      );
      final headers = await _buildHeaders();
      final response =
          await _client.get(uri, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('请求超时，请稍后重试');
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException('服务器连接失败');
    }
  }

  /// POST 请求
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders();
      final response = await _client
          .post(uri, headers: headers, body: json.encode(body ?? {}))
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('请求超时，请稍后重试');
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException('服务器连接失败');
    }
  }

  /// PUT 请求
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders();
      final response = await _client
          .put(uri, headers: headers, body: json.encode(body ?? {}))
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('请求超时，请稍后重试');
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException('服务器连接失败');
    }
  }

  /// DELETE 请求
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final headers = await _buildHeaders();
      final response =
          await _client.delete(uri, headers: headers).timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('请求超时，请稍后重试');
    } on SocketException {
      throw NetworkException();
    } on HttpException {
      throw NetworkException('服务器连接失败');
    }
  }
}
