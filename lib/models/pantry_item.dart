/// 库存物品模型
class PantryItem {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final DateTime expirationDate;
  final String status;
  final String statusLabel;
  final String? notes;
  final DateTime createdAt;

  PantryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
    required this.status,
    required this.statusLabel,
    this.notes,
    required this.createdAt,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      expirationDate: DateTime.parse(json['expiration_date'] as String),
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// 首页最近添加物品（简略信息）
class RecentItem {
  final String id;
  final String name;
  final int quantity;
  final String unit;

  RecentItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecentItem.fromJson(Map<String, dynamic> json) {
    return RecentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
    );
  }
}

/// 厨房库存概览
class PantryOverview {
  final int totalItems;
  final int expiringCount;
  final int expiredCount;
  final int freshCount;
  final List<RecentItem> recentItems;

  PantryOverview({
    required this.totalItems,
    required this.expiringCount,
    required this.expiredCount,
    required this.freshCount,
    required this.recentItems,
  });

  factory PantryOverview.fromJson(Map<String, dynamic> json) {
    final rawItems = json['recent_items'] as List<dynamic>;
    return PantryOverview(
      totalItems: json['total_items'] as int,
      expiringCount: json['expiring_count'] as int,
      expiredCount: json['expired_count'] as int,
      freshCount: json['fresh_count'] as int,
      recentItems: rawItems
          .map((e) => RecentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
