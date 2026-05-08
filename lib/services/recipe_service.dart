import 'package:PantryPal/models/recipe.dart';
import 'package:PantryPal/services/api_client.dart';

/// 菜谱推荐服务
class RecipeService {
  final _client = ApiClient.instance;

  /// 获取推荐菜谱列表
  Future<List<RecipeSuggestion>> getSuggestions({int limit = 5}) async {
    final response = await _client.get(
      '/api/recipes/suggestions',
      queryParams: {'limit': limit.toString()},
    );
    final rawList = response['data'] as List<dynamic>;
    return rawList
        .map((e) => RecipeSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取菜谱详情
  Future<RecipeDetail> getDetail(String recipeId) async {
    final response = await _client.get('/api/recipes/$recipeId');
    return RecipeDetail.fromJson(response['data'] as Map<String, dynamic>);
  }
}
