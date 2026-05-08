import 'package:flutter/foundation.dart';

import 'package:PantryPal/models/user.dart';
import 'package:PantryPal/services/auth_service.dart';
import 'package:PantryPal/utils/token_manager.dart';

/// 全局登录态管理（单例 ChangeNotifier）
///
/// 用于在 widget tree 中共享登录状态，监听登录/退出事件。
class AuthNotifier extends ChangeNotifier {
  static final AuthNotifier _instance = AuthNotifier._();
  static AuthNotifier get instance => _instance;

  AuthNotifier._();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// 登录成功后调用：存 token + 更新用户信息
  Future<void> login(AuthData authData) async {
    await TokenManager.instance.saveToken(authData.token);
    _currentUser = authData.user;
    notifyListeners();
  }

  /// 退出登录：清 token + 清用户信息
  Future<void> logout() async {
    try {
      await AuthService().logout();
    } catch (e) {
      // 退出登录即使 API 调用失败也继续清理本地状态
      debugPrint('AuthService.logout error: $e');
    }
    await TokenManager.instance.clearToken();
    _currentUser = null;
    notifyListeners();
  }

  /// 启动时尝试自动登录：检查本地是否有有效 token
  ///
  /// 返回 true 表示有 token（可能已过期，首次 API 调用时会触发 401）
  Future<bool> tryAutoLogin() async {
    final hasToken = await TokenManager.instance.hasToken();
    return hasToken;
  }

  /// 直接设置用户信息（用于从 API 获取 profile 后更新）
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// 清除状态（401 时由 ApiClient 调用）
  Future<void> clearAuth() async {
    await TokenManager.instance.clearToken();
    _currentUser = null;
    notifyListeners();
  }
}
