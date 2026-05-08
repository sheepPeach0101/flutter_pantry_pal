/// 单日使用量
class DailyUsage {
  final String date;
  final int count;

  DailyUsage({
    required this.date,
    required this.count,
  });

  factory DailyUsage.fromJson(Map<String, dynamic> json) {
    return DailyUsage(
      date: json['date'] as String,
      count: json['count'] as int,
    );
  }
}

/// 月度统计概览
class MonthlyStats {
  final int periodDays;
  final double usageRate;
  final int usedItemsCount;
  final int wasteCount;
  final double wasteGrowthRate;
  final double totalValue;
  final String currency;
  final double avgShelfLifeDays;
  final double shelfLifeImprovementDays;
  final List<DailyUsage> dailyUsage;

  MonthlyStats({
    required this.periodDays,
    required this.usageRate,
    required this.usedItemsCount,
    required this.wasteCount,
    required this.wasteGrowthRate,
    required this.totalValue,
    required this.currency,
    required this.avgShelfLifeDays,
    required this.shelfLifeImprovementDays,
    required this.dailyUsage,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    final rawUsage = json['daily_usage'] as List<dynamic>;
    return MonthlyStats(
      periodDays: json['period_days'] as int,
      usageRate: (json['usage_rate'] as num).toDouble(),
      usedItemsCount: json['used_items_count'] as int,
      wasteCount: json['waste_count'] as int,
      wasteGrowthRate: (json['waste_growth_rate'] as num).toDouble(),
      totalValue: (json['total_value'] as num).toDouble(),
      currency: json['currency'] as String,
      avgShelfLifeDays: (json['avg_shelf_life_days'] as num).toDouble(),
      shelfLifeImprovementDays:
          (json['shelf_life_improvement_days'] as num).toDouble(),
      dailyUsage: rawUsage
          .map((e) => DailyUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 常用物品排行
class TopUsedItem {
  final String name;
  final int usageCount;
  final String? icon;

  TopUsedItem({
    required this.name,
    required this.usageCount,
    this.icon,
  });

  factory TopUsedItem.fromJson(Map<String, dynamic> json) {
    return TopUsedItem(
      name: json['name'] as String,
      usageCount: json['usage_count'] as int,
      icon: json['icon'] as String?,
    );
  }
}
