import 'package:PantryPal/models/user.dart';
import 'package:PantryPal/services/api_client.dart';

/// 用户信息服务
class UserService {
  final _client = ApiClient.instance;

  /// 获取当前用户资料
  Future<User> getProfile() async {
    final response = await _client.get('/api/user/profile');
    return User.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 更新用户资料（部分更新）
  Future<User> updateProfile({
    String? name,
    String? avatar,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (avatar != null) body['avatar'] = avatar;
    if (phone != null) body['phone'] = phone;

    final response = await _client.put('/api/user/profile', body: body);
    return User.fromJson(response['data'] as Map<String, dynamic>);
  }
}
