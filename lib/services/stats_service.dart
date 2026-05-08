import 'package:PantryPal/models/stats.dart';
import 'package:PantryPal/services/api_client.dart';

/// 统计报告服务
class StatsService {
  final _client = ApiClient.instance;

  /// 获取月度统计
  Future<MonthlyStats> getMonthlyStats({int days = 30}) async {
    final response = await _client.get(
      '/api/stats/monthly',
      queryParams: {'days': days.toString()},
    );
    return MonthlyStats.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// 获取常用物品排行
  Future<List<TopUsedItem>> getTopUsed({int limit = 10}) async {
    final response = await _client.get(
      '/api/stats/top-used',
      queryParams: {'limit': limit.toString()},
    );
    final rawList = response['data'] as List<dynamic>;
    return rawList
        .map((e) => TopUsedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
