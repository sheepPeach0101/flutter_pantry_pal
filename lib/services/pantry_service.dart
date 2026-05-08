import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/models/api_response.dart';
import 'package:PantryPal/services/api_client.dart';

/// 厨房物品服务（CRUD + 概览）
class PantryService {
  final _client = ApiClient.instance;

  /// 获取库存列表（分页 + 筛选）
  Future<PaginatedData<PantryItem>> getItems({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? keyword,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (status != null) params['item_status'] = status;
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

    final response = await _client.get('/api/pantry/items', queryParams: params);
    final data = response['data'] as Map<String, dynamic>;
    return PaginatedData.fromJson(data, PantryItem.fromJson);
  }

  /// 获取库存概览
  Future<PantryOverview> getOverview() async {
    final response = await _client.get('/api/pantry/overview');
    return PantryOverview.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 新增物品
  Future<PantryItem> createItem({
    required String name,
    required int quantity,
    required String unit,
    required String expirationDate,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'expiration_date': expirationDate,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final response = await _client.post('/api/pantry/items', body: body);
    return PantryItem.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 更新物品（部分更新）
  Future<PantryItem> updateItem(
    String itemId, {
    String? name,
    int? quantity,
    String? unit,
    String? expirationDate,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (quantity != null) body['quantity'] = quantity;
    if (unit != null) body['unit'] = unit;
    if (expirationDate != null) body['expiration_date'] = expirationDate;
    if (notes != null) body['notes'] = notes;

    final response =
        await _client.put('/api/pantry/items/$itemId', body: body);
    return PantryItem.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 删除物品
  Future<void> deleteItem(String itemId) async {
    await _client.delete('/api/pantry/items/$itemId');
  }
}
