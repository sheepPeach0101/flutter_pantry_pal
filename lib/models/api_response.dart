/// 统一 API 响应信封
class ApiResponse {
  final int code;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 200 || code == 201;

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }
}

/// 分页数据结构
class PaginatedData<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  PaginatedData({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawItems = json['items'] as List<dynamic>;
    return PaginatedData<T>(
      items: rawItems
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}
