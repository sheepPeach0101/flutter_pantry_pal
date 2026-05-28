/// 食材使用记录模型
class UsageLog {
  final String id;
  final String? itemId;
  final String itemName;
  final int quantity;
  final String unit;
  final DateTime usedAt;

  UsageLog({
    required this.id,
    this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.usedAt,
  });

  factory UsageLog.fromJson(Map<String, dynamic> json) {
    return UsageLog(
      id: json['id'] as String,
      itemId: json['item_id'] as String?,
      itemName: json['item_name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unit: json['unit'] as String,
      usedAt: DateTime.parse(json['used_at'] as String),
    );
  }
}
