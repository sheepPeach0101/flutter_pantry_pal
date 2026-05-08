/// API 业务异常（后端返回的错误）
class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => 'ApiException($code): $message';
}

/// 网络连接异常
class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = '网络连接失败，请检查网络']);

  @override
  String toString() => 'NetworkException: $message';
}

/// 认证过期异常
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = '登录已过期，请重新登录']);

  @override
  String toString() => 'UnauthorizedException: $message';
}
