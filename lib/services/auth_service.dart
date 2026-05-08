import 'package:PantryPal/models/user.dart';
import 'package:PantryPal/services/api_client.dart';

/// 认证服务（注册/登录/退出）
class AuthService {
  final _client = ApiClient.instance;

  /// 用户注册
  Future<AuthData> signup(String email, String password) async {
    final response = await _client.post('/api/auth/signup', body: {
      'email': email,
      'password': password,
    });
    return AuthData.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 用户登录
  Future<AuthData> login(String email, String password) async {
    final response = await _client.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    return AuthData.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 退出登录
  Future<void> logout() async {
    await _client.post('/api/auth/logout');
  }
}
