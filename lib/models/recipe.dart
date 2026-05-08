/// 菜谱食材（含是否在库存中）
class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;
  final bool inPantry;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.inPantry,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      inPantry: json['in_pantry'] as bool? ?? false,
    );
  }
}

/// 菜谱步骤
class RecipeStep {
  final int order;
  final String description;

  RecipeStep({
    required this.order,
    required this.description,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      order: json['order'] as int,
      description: json['description'] as String,
    );
  }
}

/// 菜谱详情
class RecipeDetail {
  final String id;
  final String title;
  final String? coverImage;
  final String? description;
  final int cookingTimeMinutes;
  final int servings;
  final String difficulty;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  RecipeDetail({
    required this.id,
    required this.title,
    this.coverImage,
    this.description,
    required this.cookingTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'] as List<dynamic>;
    final rawSteps = json['steps'] as List<dynamic>;
    return RecipeDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      coverImage: json['cover_image'] as String?,
      description: json['description'] as String?,
      cookingTimeMinutes: json['cooking_time_minutes'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      ingredients: rawIngredients
          .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      steps: rawSteps
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 推荐菜谱（摘要）
class RecipeSuggestion {
  final String id;
  final String title;
  final String? coverImage;
  final String matchReason;
  final List<String> matchedItems;
  final List<String> missingItems;
  final int missingItemsCount;
  final int cookingTimeMinutes;

  RecipeSuggestion({
    required this.id,
    required this.title,
    this.coverImage,
    required this.matchReason,
    required this.matchedItems,
    required this.missingItems,
    required this.missingItemsCount,
    required this.cookingTimeMinutes,
  });

  factory RecipeSuggestion.fromJson(Map<String, dynamic> json) {
    return RecipeSuggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      coverImage: json['cover_image'] as String?,
      matchReason: json['match_reason'] as String,
      matchedItems: (json['matched_items'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      missingItems: (json['missing_items'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      missingItemsCount: json['missing_items_count'] as int,
      cookingTimeMinutes: json['cooking_time_minutes'] as int,
    );
  }
}
