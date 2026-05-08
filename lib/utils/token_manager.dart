import 'package:shared_preferences/shared_preferences.dart';

/// JWT Token 持久化管理（单例）
class TokenManager {
  static final TokenManager _instance = TokenManager._();
  static TokenManager get instance => _instance;

  TokenManager._();

  static const _key = 'auth_token';

  /// 保存 Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  /// 读取 Token（不存在返回 null）
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// 清除 Token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 是否存在有效 Token
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
