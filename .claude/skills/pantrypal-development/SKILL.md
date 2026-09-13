---
name: pantrypal-development
description: PantryPal 厨房食材库存管理 Flutter 应用的完整开发指南，涵盖项目架构、主题系统、页面结构、API 对接模式、通用组件、工具类及编码约定。
origin: project
---

# PantryPal 开发技能

## 适用场景

在以下场景使用本技能：
- 为 PantryPal 新增页面或功能模块
- 修改或扩展现有页面 UI 和交互逻辑
- 接入后端 API 或调整网络层
- 需要了解项目当前进度、已完成/待完成内容
- 调整主题系统（颜色、字体、深色模式）

## 项目概况

PantryPal 是一款厨房食材库存管理应用，界面主要使用**简体中文**。核心功能：
- 食材库存追踪（名称、数量、有效期）
- 使用统计与损耗分析
- 基于库存的菜谱推荐
- 用户认证（注册/登录，JWT Bearer Token）

**当前阶段**：前后端 API 对接已完成，所有页面均已接入真实接口，支持完整的登录态管理与数据刷新。

## 技术栈

| 项 | 值 |
|---|---|
| 框架 | Flutter (Dart SDK >=3.0.0 <4.0.0) |
| 状态管理 | 无库（基础 setState + ChangeNotifier Singleton） |
| 路由 | MaterialApp.routes 命名路由 |
| 字体 | google_fonts (Inter + IBM Plex Sans) |
| 图标 | Material Icons + cupertino_icons |
| HTTP 客户端 | http: ^1.0.0 |
| 本地存储 | shared_preferences: ^2.2.0 |
| 国际化/日期 | intl: ^0.19.0 |
| 后端 | FastAPI (Bearer Token JWT) |

## 架构与文件结构

```
lib/
├── main.dart                      # 应用入口，路由定义，启动时 token 检查
├── theme/
│   ├── index.dart                 # AppTheme 全局主题配置
│   ├── light.dart                 # Light 浅色主题颜色定义
│   └── dark.dart                  # Dark 深色主题颜色定义（未接入）
├── models/                        # 数据模型层
│   ├── api_response.dart          # ApiResponse<T>、PaginatedData<T> 通用包装
│   ├── user.dart                  # User、AuthData
│   ├── pantry_item.dart           # PantryItem、RecentItem、PantryOverview
│   ├── stats.dart                 # DailyUsage、MonthlyStats、TopUsedItem
│   └── recipe.dart                # RecipeIngredient、RecipeStep、RecipeDetail、RecipeSuggestion
├── services/                      # 服务层（HTTP 调用）
│   ├── api_client.dart            # HTTP 单例客户端（token 注入、统一错误处理）
│   ├── auth_service.dart          # signup / login / logout
│   ├── pantry_service.dart        # CRUD + 分页 + 概览
│   ├── user_service.dart          # getProfile / updateProfile
│   ├── stats_service.dart         # getMonthlyStats / getTopUsed
│   └── recipe_service.dart        # getSuggestions / getDetail
├── utils/                         # 工具层
│   ├── exceptions.dart            # ApiException、NetworkException、UnauthorizedException
│   ├── token_manager.dart         # JWT token SharedPreferences 封装（单例）
│   └── auth_notifier.dart         # 登录态 ChangeNotifier（单例）
├── widgets/                       # 跨页面复用组件（2026-05-26 新建）
│   ├── edit_item_modal.dart       # 食材编辑弹窗（预填字段 + updateItem）
│   └── item_action_sheet.dart     # 食材操作面板（编辑/使用占位/删除）
└── views/                         # 视图层
    ├── welcome.dart               # 欢迎页（初始路由 /welcome）
    ├── signup.dart                # 注册页（/signup）
    ├── login.dart                 # 登录页（/login）
    ├── navigation_wrapper.dart    # 底部导航容器 + AddItemModal
    ├── home.dart                  # 首页概览（/home）
    ├── inventory.dart             # 库存列表页
    ├── stats.dart                 # 统计页
    └── profile.dart               # 个人中心页
```

## 路由表

```dart
'/welcome' → WelcomePage    // 初始路由（未登录）
'/signup'  → SignupPage
'/login'   → LoginPage
'/home'    → MainNavigation // 底部导航容器（已登录）
```

启动时路由决策（`main.dart`）：

```dart
WidgetsFlutterBinding.ensureInitialized();
final token = await TokenManager.instance.getToken();
final initialRoute = token != null ? '/home' : '/welcome';
```

## 导航结构

`MainNavigation` 使用 `IndexedStack` + 自定义底部导航栏：

| Index | 图标 | 页面 | 说明 |
|-------|------|------|------|
| 0 | home | HomePage | 首页概览 |
| 1 | list | InventoryPage | 库存列表 |
| 2 | add（特殊按钮） | AddItemModal | 弹窗，非页面 |
| 3 | info | StatsPage | 统计分析 |
| 4 | settings | ProfilePage | 个人中心 |

## 主题系统

### 颜色 Token（`ih_` 前缀）

| Token | 浅色值 | 用途 |
|-------|--------|------|
| `ih_accent` | #C67A52 | 主强调色（按钮、链接） |
| `ih_accent_soft` | #E09B7630 | 柔和强调色（半透明） |
| `ih_bg` | #FAF8F4 | 页面背景色 |
| `ih_surface` | #FFFFFF | 卡片/容器表面 |
| `ih_surface_warm` | #F5F2EC | 暖色表面（次要容器） |
| `ih_text` | #2C2C2C | 主要文本 |
| `ih_text_secondary` | #6B6B6B | 次要文本 |
| `ih_text_muted` | #9A9A9A | 弱化文本 |
| `ih_border` | #E5E2DC | 普通边框 |
| `ih_border_strong` | #555555 | 强调边框 |
| `ih_negative` | #E57373 | 错误/警告色 |
| `ih_positive` | #81C784 | 成功/正向色 |

### 使用方式

```dart
// 通过静态字段访问（当前仅浅色模式）
AppTheme.currentColors.ih_accent
AppTheme.currentColors.ih_bg

// 全局常量
AppTheme.radius_lg    // 16.0
AppTheme.spacing_base // 12.0
```

### 字体规范

- **标题**：`GoogleFonts.ibmPlexSans`，fontSize 18-36，w600
- **正文/标签**：`GoogleFonts.inter`，fontSize 11-14
- **统计数字**：`GoogleFonts.ibmPlexSans`，fontSize 24-36，bold

## 通用工具类

### TokenManager（`lib/utils/token_manager.dart`）

单例，封装 SharedPreferences 的 JWT token 读写：

```dart
// 存储
await TokenManager.instance.saveToken(token);

// 读取
final token = await TokenManager.instance.getToken(); // null 表示未登录

// 清除
await TokenManager.instance.clearToken();
```

### AuthNotifier（`lib/utils/auth_notifier.dart`）

单例 ChangeNotifier，管理全局登录态：

```dart
// 登录（保存 token + notifyListeners）
await AuthNotifier.instance.login(token);

// 退出（清除 token + notifyListeners）
await AuthNotifier.instance.logout();

// 清除认证状态（401 时调用）
await AuthNotifier.instance.clearAuth();

// 启动时尝试自动登录
final loggedIn = await AuthNotifier.instance.tryAutoLogin();
```

### ApiClient（`lib/services/api_client.dart`）

单例 HTTP 客户端，自动注入 Bearer Token：

```dart
// GET 请求
final response = await ApiClient.instance.get('/api/pantry/items?page=1');

// POST 请求
final response = await ApiClient.instance.post('/api/auth/login', body: {
  'email': email,
  'password': password,
});

// PUT 请求
final response = await ApiClient.instance.put('/api/pantry/items/$id', body: {...});

// DELETE 请求
final response = await ApiClient.instance.delete('/api/pantry/items/$id');
```

**内置行为**：
- 自动读取 TokenManager 并添加 `Authorization: Bearer <token>` 请求头
- HTTPS 强制（生产环境）
- 超时处理（抛出 NetworkException）
- HTTP 4xx/5xx 转换为 ApiException
- 401 不在此层处理，由视图层捕获后跳转 `/welcome`

### 异常体系（`lib/utils/exceptions.dart`）

```dart
// API 业务异常（4xx/5xx）
throw ApiException(statusCode: 400, message: '邮箱已存在');

// 网络/超时异常
throw NetworkException('请求超时，请检查网络');

// 未授权（401）
throw UnauthorizedException();
```

## 数据模型

### ApiResponse<T>（`lib/models/api_response.dart`）

```dart
// 所有 API 统一响应包装
ApiResponse<User> response = ApiResponse.fromJson(json, (data) => User.fromJson(data));

// 分页数据
PaginatedData<PantryItem> paged = PaginatedData.fromJson(json, (item) => PantryItem.fromJson(item));
// paged.items — List<PantryItem>
// paged.total — 总数
// paged.page  — 当前页
// paged.limit — 每页数量
```

### UsageLog（`lib/models/usage_log.dart`）

```dart
UsageLog log = UsageLog.fromJson(json);
// log.id — 使用记录 UUID
// log.itemId — 关联物品 UUID（物品被删除后为 null）
// log.itemName — 物品名称（冗余存储）
// log.quantity — 本次使用数量
// log.unit — 单位（冗余存储）
// log.usedAt — 使用时间（DateTime）
```

### PantryItem（`lib/models/pantry_item.dart`）

```dart
PantryItem item = PantryItem.fromJson(json);

// statusLabel getter：根据 status 字段返回 '新鲜' / '即将过期' / '已过期'
print(item.statusLabel);

// PantryOverview 用于首页概览
PantryOverview overview = PantryOverview.fromJson(json);
// overview.total / overview.fresh / overview.expiring / overview.expired
```

## 服务层使用示例

### AuthService

```dart
// 注册
await AuthService.signup(email: email, password: password, name: name);

// 登录（返回 AuthData，包含 token）
final authData = await AuthService.login(email: email, password: password);
await AuthNotifier.instance.login(authData.token);

// 退出
await AuthService.logout();
await AuthNotifier.instance.logout();
```

### PantryService

```dart
// 分页获取库存（type-safe cast）
final paged = await PantryService.getItems(page: 1, status: 'fresh');
// 注意：getItems 返回 PaginatedData<dynamic>，需要手动转换
final items = paged.items.cast<PantryItem>();

// 首页概览
final overview = await PantryService.getOverview();

// 新增物品
await PantryService.createItem(name: '西红柿', quantity: 3, unit: '个', expiryDate: date);

// 更新物品
await PantryService.updateItem(id: item.id, name: '番茄', quantity: 5);

// 删除物品
await PantryService.deleteItem(id: item.id);

// 使用食材（返回含 item 和 usage_log 的 Map）
final data = await _pantryService.useItem(item.id, quantity: 3);

// 获取使用记录（返回 PaginatedData<UsageLog>）
final paged = await _pantryService.getUsageLogs(page: 1, pageSize: 20, days: 30);
final logs = paged.items; // List<UsageLog>
```

### StatsService / RecipeService

```dart
// 月度统计（支持时间范围）
final stats = await StatsService.getMonthlyStats(days: 30); // 可传 7 / 30 / 90

// 常用物品排行
final topUsed = await StatsService.getTopUsed();

// 菜谱推荐
final suggestions = await RecipeService.getSuggestions();

// 菜谱详情
final detail = await RecipeService.getDetail(recipeId);
```

## 页面模式

### 标准异步页面模板

```dart
class SomePage extends StatefulWidget { ... }

class _SomePageState extends State<SomePage> {
  bool _isLoading = true;
  String? _error;
  SomeData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await SomeService.getData();
      if (!mounted) return;
      setState(() { _data = data; _isLoading = false; });
    } on UnauthorizedException {
      if (!mounted) return;
      await AuthNotifier.instance.clearAuth();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _isLoading = false; });
    } on NetworkException {
      if (!mounted) return;
      setState(() { _error = '网络异常，请检查连接'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_data == null) return const Center(child: Text('暂无数据'));
    // 正常渲染...
  }
}
```

### RefreshIndicator（下拉刷新）

HomePage、InventoryPage、StatsPage 均已接入：

```dart
RefreshIndicator(
  onRefresh: _loadData,
  child: ListView(...),
)
```

### 并行 API 请求（首页使用）

```dart
final results = await Future.wait([
  PantryService.getOverview(),
  PantryService.getItems(page: 1),
  RecipeService.getSuggestions(),
  StatsService.getTopUsed(),
]);
```

### Modal 返回值刷新父页面

AddItemModal 返回 `bool`，父页面 await 后按需刷新：

```dart
// navigation_wrapper.dart
final added = await showModalBottomSheet<bool>(
  context: context,
  builder: (_) => const AddItemModal(),
);
if (added == true) {
  // 通知各子页面刷新
}
```

### SnackBar 跨 Navigator.pop 的正确写法

```dart
// 在 Navigator.pop 之前捕获 messenger 引用
final messenger = ScaffoldMessenger.of(context);
Navigator.pop(context, true); // 先 pop
messenger.showSnackBar(        // 再 show
  const SnackBar(content: Text('物品已添加')),
);
```

### 卡片点击触发 ActionSheet（InventoryPage 模式）

InventoryPage 的食材卡片点击后弹出 `ItemActionSheet`，删除逻辑完全迁移到操作面板。
**Dismissible 已移除**，由 `InkWell` + 操作面板两步确认替代。

```dart
// _buildStockItem：用 Material + InkWell 包裹卡片，提供 ripple 点击效果
Widget _buildStockItem(PantryItem item) {
  return Material(
    color: AppTheme.currentColors.ih_surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () => _showActionSheet(item),
      borderRadius: BorderRadius.circular(16),
      splashColor: AppTheme.currentColors.ih_accent.withValues(alpha: 0.08),
      highlightColor: AppTheme.currentColors.ih_surface_warm,
      child: Container(padding: const EdgeInsets.all(16), child: /* ... */),
    ),
  );
}

// _showActionSheet：弹出操作面板，处理返回的操作信号
Future<void> _showActionSheet(PantryItem item) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => ItemActionSheet(item: item),
  );
  if (!mounted) return;
  if (action == 'edit') {
    await _showEditModal(item);
  } else if (action == 'use') {
    await _showUseDialog(item);
  } else if (action == 'delete') {
    await _confirmAndDelete(item);
  }
}

// _showUseDialog：在父页面 context 中弹出 UseItemDialog，成功后刷新列表
Future<void> _showUseDialog(PantryItem item) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => UseItemDialog(item: item),
  );
  if (result == true && mounted) {
    await _loadData();
  }
}

// _confirmAndDelete：在父页面 context 中弹确认对话框，再调用删除 API
Future<void> _confirmAndDelete(PantryItem item) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('确认删除'),
      content: Text('确定要删除"\${item.name}"吗？此操作不可恢复。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Colors.red))),
      ],
    ),
  );
  if (confirm != true) return;
  await _pantryService.deleteItem(item.id);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('删除成功')));
    _loadData();
  }
}
```

**关键点**：
- 删除确认对话框必须在父页面（InventoryPage）的 context 中弹出，不能在 ActionSheet 内部调用 `showDialog`，否则 ActionSheet 关闭后 context 失效
- `_showActionSheet` 是 `async`，await ActionSheet 返回值后再检查 `mounted` 和 action 值
- `InkWell` 必须放在 `Material` 内部才能显示 ripple 效果（否则 ripple 不可见）

### 401 统一处理模式

所有页面在 catch UnauthorizedException 时必须先调用 clearAuth 再跳转，且每个 async 步骤后检查 mounted：

```dart
on UnauthorizedException {
  if (!mounted) return;
  await AuthNotifier.instance.clearAuth();
  if (!mounted) return;  // clearAuth 是 async，await 后再检查一次
  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
}
```

### 退出登录确认对话框

ProfilePage 已实现，其他需要确认操作的场景可复用此模式：

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('确认退出'),
    content: const Text('确定要退出登录吗？'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认')),
    ],
  ),
);
if (confirmed == true) { /* 执行退出 */ }
```

## 页面功能详情

### WelcomePage
- 应用 Logo 占位（kitchen 图标）
- 标题 "PantryPal" + 副标题 "您的智能厨房管家"
- 箭头按钮 → `/signup`
- 文字链接 "已有账号？去登录" → `/login`

### SignupPage
- 邮箱 + 密码输入框（密码最短 8 位校验）
- 提交调用 AuthService.signup，成功后 → `/home`
- 底部链接 → `/login`

### LoginPage
- 邮箱 + 密码输入框，loading 状态
- 提交调用 AuthService.login，成功保存 token → `/home`
- 错误提示显示在表单下方

### HomePage
- 欢迎标题 + 库存总量（来自 PantryOverview）
- 搜索栏（防抖 300ms + 搜索结果浮层，Stack + Positioned 实现；聚焦态 ih_accent 边框+阴影；Semantics label='搜索厨房物品'）
- 厨房概览 Wrap 网格（_OverviewCard 独立 StatefulWidget，可点击跳转筛选）
- 过期物品提醒横幅（expiredCount > 0 时显示，ripple-only，深红 #C0392B；Material+InkWell+Ink 三层结构）
- 管理卡片（添加物品触发 AddItemModal，成功后刷新）
- 常用物品列表（可点击，InkWell+Material；点击后搜索对应 PantryItem 并弹出 ItemActionSheet；支持过期拦截）
- 推荐菜谱卡片（RecipeService.getSuggestions）
- Future.wait 并行加载 3 个接口（overview + topUsed + suggestions；月度统计已移除）+ RefreshIndicator
- State 类已公开为 `HomePageState`（可由 GlobalKey 访问）
- 三个跨 Tab 回调：`onNavigateToInventory`、`onSwitchTab`、`onSwitchToInventoryWithSearch`
- `refresh()` 公开方法：供外部（MainNavigation）在切换到 Tab 0 时触发刷新
- `_loadData()` 加防重入（if _isLoading return），`_isLoading` 初始值为 false
- 首页板块顺序：Header → 搜索栏 → 厨房概览 → 过期提醒 → 管理卡片 → 常用物品 → 推荐菜谱
- 全局 GestureDetector（behavior: HitTestBehavior.translucent）捕获点击空白区域，关闭搜索浮层但不清空内容

### InventoryPage
- 顶部 Header：默认态（标题 + 搜索图标）/ 搜索模式（搜索框 + 取消按钮），AnimatedSwitcher + FadeTransition 切换（必须为两个子 Widget 赋予不同 key 才能触发动画）
- 状态筛选 Chip（全部 / 新鲜 / 即将过期 / 已过期）；搜索提交时分类自动重置为"全部"，取消搜索时保留当前分类
- 食材卡片点击弹出 ItemActionSheet（编辑 / 使用 / 删除，三项均已激活）
- 过期拦截：edit/use 操作前，若 item.status == 'expired' 先弹 _showExpiredWarning() 确认，用户取消则放弃操作
- 删除：ActionSheet 返回 'delete' 信号 → InventoryPage 弹确认对话框 → 调用删除 API
- 使用：ActionSheet 返回 'use' 信号（过期拦截后）→ InventoryPage._showUseDialog → showDialog UseItemDialog
- 编辑：ActionSheet 返回 'edit' 信号（过期拦截后）→ InventoryPage._showEditModal → showModalBottomSheet EditItemModal
- Dismissible 已移除（迁移到 ActionSheet 删除流程）
- 搜索支持 keyword 参数（_searchKeyword 传入 PantryService.getItems）；键盘提交触发（非防抖），清除时保留分类，取消时保留分类
- 分页加载（PantryService.getItems + status + keyword 参数）
- 推荐菜谱卡片
- RefreshIndicator
- State 类已公开为 `InventoryPageState`（可由 GlobalKey 访问）
- `refresh()` 公开方法：供外部在切换到 Tab 1 时触发刷新
- `applyFilter(String? status)` 公开方法：切换筛选状态并刷新（由 HomePage 回调跳转时调用）
- `applySearch(String keyword, {String? autoShowActionSheetForItem})` 公开方法：进入搜索模式、预填关键词、重置分类为"全部"并刷新，支持加载完成后通过 addPostFrameCallback 自动弹出指定物品的 ActionSheet
- `_loadData()` 加防重入（if _isLoading return），`_isLoading` 初始值为 false
- `dispose()` 中释放 `_searchController`

### StatsPage
- PopupMenuButton 时间范围切换（7 天 / 30 天 / 90 天）
- 月度概览进度条（StatsService.getMonthlyStats）
- 图表占位符（待引入 fl_chart）
- 前三常用物品展示（StatsService.getTopUsed）
- RefreshIndicator

### ProfilePage
- UserService.getProfile 加载用户信息
- 用户头像 + 姓名 + 邮箱
- 操作按钮：编辑资料、偏好设置、退出登录
- 退出登录：确认对话框 → AuthService.logout → AuthNotifier.logout → `/welcome`
- 401 自动跳转 `/welcome`

### AddItemModal（底部弹窗）
- 真实 TextEditingController（名称/数量/单位/备注）
- 日期选择器（showDatePicker）
- 提交调用 PantryService.createItem
- 成功后 pop(true) + SnackBar 提示

## API 接口汇总

### 认证
| 方法 | 路由 | 说明 |
|------|------|------|
| POST | `/api/auth/signup` | 用户注册 |
| POST | `/api/auth/login` | 用户登录，返回 JWT token |
| POST | `/api/auth/logout` | 用户退出 |

### 物品管理
| 方法 | 路由 | 说明 |
|------|------|------|
| GET | `/api/pantry/items` | 获取库存列表（分页 + status 筛选） |
| GET | `/api/pantry/overview` | 库存概览（总数/新鲜/即将过期/已过期） |
| POST | `/api/pantry/items` | 新增物品 |
| PUT | `/api/pantry/items/{id}` | 更新物品 |
| DELETE | `/api/pantry/items/{id}` | 删除物品 |
| POST | `/api/pantry/items/{id}/use` | 使用食材，扣减库存并写入使用记录 |
| GET | `/api/pantry/usage-logs` | 获取使用记录（分页 + days 时间范围） |

### 用户信息
| 方法 | 路由 | 说明 |
|------|------|------|
| GET | `/api/user/profile` | 获取个人资料 |
| PUT | `/api/user/profile` | 更新个人资料 |

### 统计
| 方法 | 路由 | 说明 |
|------|------|------|
| GET | `/api/stats/monthly` | 月度概览（支持 days 参数：7/30/90） |
| GET | `/api/stats/top-used` | 常用物品排行 |

### 菜谱
| 方法 | 路由 | 说明 |
|------|------|------|
| GET | `/api/recipes/suggestions` | 基于库存的菜谱推荐 |
| GET | `/api/recipes/{id}` | 菜谱详情 |

### 公共规范
- Content-Type: `application/json`
- 认证: `Authorization: Bearer <token>`（由 ApiClient 自动注入）
- 成功格式: `{ "success": true, "data": {...} }`
- 错误格式: `{ "success": false, "error": "错误信息" }`

## 编码约定

### 新增页面模板

```dart
import 'package:PantryPal/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // 页面内容...
              const SizedBox(height: 100), // 底部导航栏留白
            ],
          ),
        ),
      ),
    );
  }
}
```

### 样式规范
- 页面水平内边距：`24`
- 区块间距：`32`（大）、`12`（小）
- 卡片圆角：`16`-`20`
- 按钮圆角：`12`
- 底部留白：`100`（给底部导航栏）
- 包名导入使用 `package:PantryPal/...`

## 注意事项 / 踩坑记录

### async 后必须检查 mounted

每次 `await` 之后，在操作 `context`、`setState`、`Navigator` 之前必须检查 `mounted`：

```dart
await someAsyncCall();
if (!mounted) return; // 必须，Widget 可能已被销毁
setState(() { ... });
```

特别注意：`clearAuth()` 和 `logout()` 本身是 async，await 之后需要再次检查 mounted。

### SnackBar 不能在 Navigator.pop 之后通过 context 获取

`Navigator.pop(context)` 后 context 对应的 Scaffold 可能已卸载，必须在 pop 之前捕获 `ScaffoldMessenger.of(context)`。

### PaginatedData 的类型安全

`PantryService.getItems()` 内部返回 `PaginatedData<dynamic>`，调用方需手动 cast：

```dart
final paged = await PantryService.getItems(page: 1);
final items = paged.items.cast<PantryItem>(); // 必须显式 cast
```

### Dart SDK 已升级到 3.x

`pubspec.yaml` 中 SDK 约束已从 `>=2.19.0 <3.0.0` 升级为 `>=3.0.0 <4.0.0`，可以使用 sealed classes、records、pattern matching 等 Dart 3 特性。

### 401 处理不在 ApiClient 层

ApiClient 不主动处理 401，仅抛出 `UnauthorizedException`，由各视图层负责 clearAuth + 跳转。这样避免 HTTP 层直接依赖 Navigator。

### TimeoutException 需要额外 import

```dart
import 'dart:async'; // 需要显式导入才能捕获 TimeoutException
```

### AddItemModal 返回值

`showModalBottomSheet` 调用后需要 await 其返回值，才能在 modal 关闭后触发父页面刷新：

```dart
final result = await showModalBottomSheet<bool>(...);
if (result == true) _loadData();
```

### 已知问题
- `Light` 和 `Dark` 类无共同接口，切换主题需先抽象
- StatsPage 图表为 Container 占位符，待引入 fl_chart
- 菜谱详情页（`/recipe-detail`）和编辑个人资料页（`/edit-profile`）尚未实现
- 偏好设置页面尚未实现

## 可复用组件（lib/widgets/）

本目录在 2026-05-26 新建，用于存放跨页面复用的弹窗和面板组件。

### EditItemModal（`lib/widgets/edit_item_modal.dart`）

编辑食材信息的浮动卡片弹窗，与 AddItemModal 视觉风格完全一致。

```dart
// 调用方式（InventoryPage 或 ItemActionSheet 之后的父页面）
final result = await showModalBottomSheet<bool>(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (_) => EditItemModal(item: item, onRefresh: _loadData),
);
if (result == true) _loadData();
```

关键实现细节：
- `initState` 中用 `item` 数据初始化所有 TextEditingController
- 日期 `firstDate: DateTime(2000, 1, 1)`（允许选历史日期，与 AddItemModal 的 `DateTime.now()` 不同）
- 提交后 `Navigator.pop(context, true)` + SnackBar 显示"修改成功"
- SnackBar 在 `pop` 之前捕获 `ScaffoldMessenger.of(context)` 引用，避免 context 失效
- loading 期间禁用所有输入框（`enabled: !_isSubmitting`）

### ItemActionSheet（`lib/widgets/item_action_sheet.dart`）

食材卡片点击后弹出的底部操作面板，提供编辑、使用、删除三个入口（三个入口均已激活）。

```dart
// 调用方式（InventoryPage 中）
final action = await showModalBottomSheet<String>(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (_) => ItemActionSheet(item: item),
);
if (!mounted) return;
if (action == 'edit') {
  await _showEditModal(item);
} else if (action == 'use') {
  await _showUseDialog(item);
} else if (action == 'delete') {
  await _confirmAndDelete(item);
}
```

关键实现细节：
- 删除：`Navigator.pop(context, 'delete')` 返回信号，由父页面弹确认对话框
- 编辑：`Navigator.pop(context, 'edit')` 返回信号，由父页面弹出 EditItemModal
- 使用（已激活）：`Navigator.pop(context, 'use')` 返回信号，由父页面调用 `showDialog` 弹出 UseItemDialog；图标色 `ih_accent`，文字色 `ih_text`，副文字"记录消耗"（11pt, `ih_text_muted`）
- 构造函数只需 `item` 参数，无 `onRefresh` 回调，所有后续操作由父页面统一处理

### UseItemDialog（`lib/widgets/use_item_dialog.dart`）

使用食材的居中弹窗（Dialog，非 BottomSheet），单字段数量输入，支持步进按钮与输入框双向联动。

```dart
// 调用方式（InventoryPage._showUseDialog — 在父页面 context 中调用）
final result = await showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => UseItemDialog(item: item),
);
if (result == true && mounted) await _loadData();
```

关键实现细节：
- `barrierDismissible: false`：防止误触关闭（输入中）
- 步进按钮减号：`_quantity <= 1` 时禁用；加号：`_quantity >= item.quantity` 时禁用
- TextField 与 `_quantity` 状态变量双向联动（listener 监听文本变化，步进按钮更新 controller.text）
- 校验在"确认使用"点击时触发（非实时），失败显示 ErrorBanner
- 成功后：先缓存 `ScaffoldMessenger.of(context)` → `Navigator.pop(context, true)` → `messenger.showSnackBar(...)`
- SnackBar 文案：`'已使用 $qty ${item.unit} ${item.name}'`
- Loading 期间取消按钮和确认按钮均禁用（防重复提交）

## 跨 Tab 通信机制（MainNavigation）

`MainNavigation` 通过 `GlobalKey` 持有子页面 State 的引用，实现 Tab 间的主动通信：

```dart
// navigation_wrapper.dart 核心结构
final _homeKey = GlobalKey<HomePageState>();
final _inventoryKey = GlobalKey<InventoryPageState>();

// 切换 Tab 时主动刷新目标页
void _onTabTapped(int index) {
  if (index == 0) _homeKey.currentState?.refresh();
  if (index == 1) _inventoryKey.currentState?.refresh();
  setState(() => _currentIndex = index);
}

// 从任意来源跳转到 InventoryPage 并筛选
void _switchToInventoryWithFilter(String? filter) {
  setState(() => _currentIndex = 1);
  _inventoryKey.currentState?.applyFilter(filter);
}

// 从任意来源跳转到 InventoryPage 并触发搜索（可选自动弹出 ActionSheet）
void _switchToInventoryWithSearch(String keyword, {String? targetItemName}) {
  setState(() => _currentIndex = 1);
  _inventoryKey.currentState?.applySearch(
    keyword,
    autoShowActionSheetForItem: targetItemName,
  );
}
```

**注意事项**：
- `_pages` 列表在 `initState` 中初始化（非 final 字段），因为需要在构造时传入 key
- `GlobalKey.currentState` 可能为 null（Widget 未挂载时），始终用 `?.` 调用
- `applySearch` 中 `autoShowActionSheetForItem` 逻辑依赖 `_loadData()` 完成后的 `_items` 列表，使用 async/await 顺序执行，await 后必须检查 mounted

## 概览卡片点击态模式（_OverviewCard）

每个概览卡片独立为 `StatefulWidget`，用 `onHighlightChanged` 驱动 `AnimatedScale` 缩放，而非 `onTap: null` 禁用 ripple。这样可以同时保留 ripple 水波纹和缩放动画。

```dart
class _OverviewCard extends StatefulWidget {
  const _OverviewCard({
    required this.label,
    required this.count,
    required this.cardColor,
    required this.rippleColor,
    required this.status,   // 语义锚点，筛选参数由 onTap 回调传入
    required this.onTap,
  });
  // ...
}

class _OverviewCardState extends State<_OverviewCard> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isHighlighted ? 0.95 : 1.0,
      duration: _isHighlighted
          ? const Duration(milliseconds: 100)
          : const Duration(milliseconds: 150),
      curve: _isHighlighted ? Curves.easeInOut : Curves.easeOut,
      child: Material(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onHighlightChanged: (highlighted) {
            setState(() => _isHighlighted = highlighted);
          },
          onTap: widget.onTap,   // onTap 必须非 null，否则 ripple 不触发
          // ...
        ),
      ),
    );
  }
}
```

**关键点**：
- `onTap` 不能为 null，否则 InkWell 不响应触摸，ripple 和 onHighlightChanged 均不触发
- 每个卡片独立 State，多个卡片同时使用时不会共用 `_isHighlighted` 导致错误高亮
- 按压时 `elevation` 从 1.5 降到 0.5，配合 AnimatedScale 提供立体按压感

## 过期提醒横幅（ExpiredAlertCard 模式）

横幅设计要点：仅 ripple，无缩放；数量上限 99+；深红色 #C0392B（主题暂无 token，直接硬编码）。

```dart
Widget _buildExpiredAlert() {
  final expiredCount = _overview?.expiredCount ?? 0;
  if (expiredCount <= 0) return const SizedBox.shrink();

  final countLabel = expiredCount >= 100 ? '99+' : '$expiredCount';
  const deepRed = Color(0xFFC0392B); // 设计稿指定，不使用 ih_negative（对比度更高）

  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => widget.onNavigateToInventory?.call('expired'),
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.currentColors.ih_negative.withValues(alpha: 0.12),
        highlightColor: AppTheme.currentColors.ih_negative.withValues(alpha: 0.06),
        child: Ink(   // 必须用 Ink 包裹背景 decoration，否则 ripple 会覆盖背景
          decoration: BoxDecoration(
            color: AppTheme.currentColors.ih_negative.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.currentColors.ih_negative.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: Padding(/* ... */),
        ),
      ),
    ),
  );
}
```

**关键点**：
- `Material + InkWell + Ink` 三层结构：Material 提供 ripple 绘制层，InkWell 捕获触摸，Ink 保留背景色（否则按压时背景色被 ripple 覆盖消失）
- 数量上限：`expiredCount >= 100 ? '99+' : '$expiredCount'`（设计规范，超过 99 时不显示真实数字）
- 横幅采用 ih_negative 色系（非 deepRed），只有数字/图标/箭头使用 deepRed，正文使用 ih_text

## 首页搜索防抖 + 竞态保护模式

```dart
// 状态变量
final TextEditingController _searchController = TextEditingController();
final FocusNode _searchFocusNode = FocusNode();
List<PantryItem> _searchResults = [];
bool _isSearchLoading = false;
bool _isSearching = false;      // 控制浮层显示
String _searchKeyword = '';     // 已生效的关键词（用于高亮）
bool _isSearchFocused = false;  // 控制边框/图标颜色
Timer? _debounceTimer;

void _onSearchChanged(String keyword) {
  _debounceTimer?.cancel();
  if (keyword.isEmpty) {
    setState(() {
      _searchResults = [];
      _isSearching = false;
      _isSearchLoading = false;
      _searchKeyword = '';
    });
    return;
  }
  // 立即进入加载态，给用户即时反馈
  setState(() {
    _isSearchLoading = true;
    _isSearching = true;
  });
  _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
    try {
      final paged = await _pantryService.getItems(keyword: keyword, pageSize: 50);
      if (!mounted) return;
      // 竞态保护：关键词与当前输入不一致则丢弃结果
      if (keyword != _searchController.text) return;
      setState(() {
        _searchKeyword = keyword;
        _searchResults = paged.items;
        _isSearchLoading = false;
      });
    } catch (_) {
      // 搜索异常优雅降级，不影响主页正常使用
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  });
}
```

**关键点**：
- 竞态保护：`if (keyword != _searchController.text) return;` 丢弃过期响应
- 键盘搜索键（TextInputAction.search）提交后只收起键盘，不清空浮层（S-2b 设计决策）：`onSubmitted: (_) => _searchFocusNode.unfocus();`
- 再次聚焦时若有缓存结果直接显示浮层，无需重新请求（在 FocusNode listener 中判断）
- 点击浮层外区域：通过 GestureDetector(behavior: HitTestBehavior.translucent) 捕获，隐藏浮层但保留内容
- `dispose()` 中必须同时释放：`_searchController.dispose()`, `_searchFocusNode.dispose()`, `_debounceTimer?.cancel()`

## 搜索结果浮层定位模式（Stack + Positioned）

将搜索框和浮层放在同一个局部 Stack 中，浮层相对于搜索框底边精准定位，避免硬编码页面级偏移量。

```dart
Stack(
  clipBehavior: Clip.none,  // 允许浮层溢出 Stack 边界
  children: [
    _buildSearchBar(),       // 搜索框（高度固定 48pt）
    if (_isSearching || _isSearchLoading)
      Positioned(
        top: 48 + 4,         // 搜索框高度 + 间距
        left: 0,
        right: 0,
        child: _buildSearchResults(),
      ),
  ],
)
```

**关键点**：
- `clipBehavior: Clip.none` 必须设置，否则浮层超出 Stack 边界会被裁剪
- 浮层高度不固定，由内容自适应
- 浮层容器使用 `boxShadow` 营造悬浮感

## 关键词高亮文本（Text.rich + TextSpan）

```dart
Widget _buildHighlightedName(String name, String keyword) {
  final normalStyle = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: colors.ih_text);
  final highlightStyle = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ih_accent);

  if (keyword.isEmpty) return Text(name, style: normalStyle, maxLines: 1, overflow: TextOverflow.ellipsis);

  final lowerName = name.toLowerCase();
  final lowerKeyword = keyword.toLowerCase();
  final index = lowerName.indexOf(lowerKeyword);

  if (index < 0) return Text(name, style: normalStyle, maxLines: 1, overflow: TextOverflow.ellipsis);

  return Text.rich(
    TextSpan(children: [
      if (index > 0) TextSpan(text: name.substring(0, index), style: normalStyle),
      TextSpan(text: name.substring(index, index + keyword.length), style: highlightStyle),
      if (index + keyword.length < name.length)
        TextSpan(text: name.substring(index + keyword.length), style: normalStyle),
    ]),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
```

**注意**：比较时使用 `toLowerCase()` 实现大小写不敏感匹配，但显示时用原始 `name` 保留原始大小写。

## 厨房物品页搜索模式（AnimatedSwitcher 两态 Header）

Header 使用 `AnimatedSwitcher` + `FadeTransition` 在默认态和搜索态之间切换，必须为两个子 Widget 赋予不同 `key` 才能触发动画。

```dart
Widget _buildHeader() {
  return SizedBox(
    height: 44,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _isSearchMode
          ? _buildSearchModeHeader(key: const ValueKey('search'))
          : _buildDefaultHeader(key: const ValueKey('default')),
    ),
  );
}
```

搜索模式行为规则：
- 搜索框以 `autofocus: true` 自动唤起键盘
- 键盘搜索键提交（`onSubmitted`）：强制将 `_selectedStatus = null`（切换到"全部"），调用 `_loadData()`（非防抖，直接触发）
- 清除按钮（X）：仅清空关键词，保留当前分类，调用 `_loadData()` 显示当前筛选的全量数据
- 取消按钮：退出搜索模式，清空关键词，**保留**当前分类 `_selectedStatus`，调用 `_loadData()`

## 过期物品操作拦截模式

在 `_showActionSheet()` 返回值处理中，对 edit/use 动作增加过期状态拦截：

```dart
Future<void> _showActionSheet(PantryItem item) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => ItemActionSheet(item: item),
  );

  if (!mounted) return;

  if (action == 'edit') {
    if (item.status == 'expired') {           // 过期拦截
      final confirmed = await _showExpiredWarning(item, 'edit');
      if (!mounted) return;
      if (!confirmed) return;                 // 用户取消则放弃
    }
    await _showEditModal(item);
  } else if (action == 'use') {
    if (item.status == 'expired') {           // 过期拦截
      final confirmed = await _showExpiredWarning(item, 'use');
      if (!mounted) return;
      if (!confirmed) return;
    }
    await _showUseDialog(item);
  } else if (action == 'delete') {
    await _confirmAndDelete(item);            // 删除不拦截
  }
}

Future<bool> _showExpiredWarning(PantryItem item, String action) async {
  final actionLabel = action == 'edit' ? '编辑' : '使用';
  final dateStr = DateFormat('yyyy-MM-dd').format(item.expirationDate);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('物品已过期'),
      content: Text('「${item.name}」已于 $dateStr 过期，确认继续$actionLabel？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('继续$actionLabel', style: const TextStyle(color: Color(0xFFE57373))),
        ),
      ],
    ),
  );
  return confirmed == true;
}
```

**注意**：每次 `await showDialog` 后都必须检查 `mounted`。

## applySearch 与 addPostFrameCallback 延迟弹窗模式

从外部（如首页搜索结果跳转）调用 `applySearch` 后，列表数据在 `_loadData()` 完成时写入 `_items`，但 Widget 树尚未重建完成，此时直接调用 `_showActionSheet` 可能找不到正确的 context。使用 `addPostFrameCallback` 延迟到帧渲染完成后再弹窗：

```dart
Future<void> applySearch(String keyword, {String? autoShowActionSheetForItem}) async {
  setState(() {
    _isSearchMode = true;
    _searchKeyword = keyword;
    _selectedStatus = null;
  });
  _searchController.text = keyword;
  await _loadData();
  if (!mounted) return;
  if (autoShowActionSheetForItem != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final match = _items.cast<PantryItem?>().firstWhere(
        (item) => item?.name == autoShowActionSheetForItem,
        orElse: () => null,
      );
      if (match != null) {
        await _showActionSheet(match);
      }
    });
  }
}
```

## 更新记录

| 日期 | 内容 |
|------|------|
| 2026-06-25 | UPDATE: home.dart — 移除月度统计板块（_buildUsageStats/_buildStatBubble/_monthlyStats），Future.wait 从 4 个减为 3 个接口；首页板块重排（常用物品移到推荐菜谱上方）；HomePageState 新增 dispose() 释放搜索资源 |
| 2026-06-25 | ADD: home.dart — 搜索防抖 + 竞态保护（_onSearchChanged，300ms Timer，keyword != controller.text 时丢弃结果）；FocusNode listener 实现再聚焦复用缓存；GestureDetector.translucent 关闭浮层但保留内容（S-2b） |
| 2026-06-25 | ADD: home.dart — 常用物品点击操作（_onTopItemTapped：PantryService.getItems 搜索匹配 → ItemActionSheet；_showActionSheet/_showEditModal/_showUseDialog/_confirmAndDelete 均已实现，含过期拦截） |
| 2026-06-25 | ADD: home.dart — "查看全部"按钮触发 onSwitchTab(1) 跳转厨房物品页 |
| 2026-06-25 | UPDATE: inventory.dart — InventoryPageState 公开（去掉 _），新增 refresh()/applyFilter()/applySearch() 三个公开方法；新增 _enterSearchMode/_exitSearchMode/_clearSearch/_onSearchSubmitted 四个内部方法 |
| 2026-06-25 | ADD: inventory.dart — _showExpiredWarning(item, action) 方法；_showActionSheet() 在 edit/use 分支新增过期拦截逻辑；使用 intl.DateFormat 格式化过期日期 |
| 2026-06-25 | UPDATE: inventory.dart — _buildHeader() 改用 AnimatedSwitcher + FadeTransition 两态切换（ValueKey 'default'/'search'），搜索模式 TextField autofocus + onSubmitted 触发搜索 |
| 2026-06-25 | UPDATE: navigation_wrapper.dart — _pages 改为 initState 中初始化（late final List）；新增 GlobalKey<HomePageState> 和 GlobalKey<InventoryPageState>；Tab 切换时主动调用 refresh()；AddItemModal 成功后通过 GlobalKey 刷新两个页面（替换空 setState） |
| 2026-06-25 | ADD: navigation_wrapper.dart — _switchToInventoryWithFilter(String? filter) 和 _switchToInventoryWithSearch(String keyword, {String? targetItemName}) 两个跨 Tab 通信方法 |
| 2026-05-28 | FIX: inventory.dart applySearch 改为 async/await 模式，消除 fire-and-forget；applyFilter 和 refresh 改为 Future<void>；_loadData 加防重入（if _isLoading return），_isLoading 初始值改为 false |
| 2026-05-28 | FIX: home.dart refresh 改为 Future<void>；_loadData 加防重入，_isLoading 初始值改为 false |
| 2026-05-28 | FIX: navigation_wrapper.dart _showAddModal 结果处理改为通过 GlobalKey 主动调用 refresh()，替换无效的空 setState |
| 2026-05-28 | UPDATE: HomePageState 公开化（去掉 _ 前缀），新增 refresh() 公开方法；HomePage 构造函数新增三个跨 Tab 回调参数 |
| 2026-05-28 | UPDATE: InventoryPageState 公开化，新增 refresh()、applyFilter()、applySearch() 三个公开方法 |
| 2026-05-28 | UPDATE: MainNavigation 新增 GlobalKey<HomePageState> 和 GlobalKey<InventoryPageState>，_pages 改为 initState 中初始化；Tab 切换时主动刷新目标页；新增 _switchToInventoryWithFilter 和 _switchToInventoryWithSearch 跨 Tab 通信方法 |
| 2026-05-27 | ADD: 新增 lib/models/usage_log.dart（UsageLog 数据模型，item_id 可为 null） |
| 2026-05-27 | ADD: PantryService 新增 useItem() 和 getUsageLogs() 两个方法，对接使用食材与查询使用记录接口 |
| 2026-05-27 | UPDATE: ItemActionSheet "使用"项从 SnackBar 占位升级为激活状态：图标色改为 ih_accent，文字色改为 ih_text，添加副文字"记录消耗"，点击返回 'use' 信号；InventoryPage._showActionSheet 新增 'use' 分支，调用 _showUseDialog 弹出 UseItemDialog |
| 2026-05-27 | ADD: 新增 lib/widgets/use_item_dialog.dart（UseItemDialog 居中弹窗，步进按钮+输入框双向联动，loading 防重复提交） |
| 2026-05-26 | UPDATE: InventoryPage 集成 ItemActionSheet 和 EditItemModal；移除 Dismissible，改为卡片点击 → 操作面板 → 两步确认删除；新增 InkWell+Material 卡片点击模式说明 |
| 2026-05-26 | ADD: 新建 lib/widgets/ 目录，新增 EditItemModal 和 ItemActionSheet 两个组件 |
| 2026-05-07 | 前后端 API 对接全量完成：新增 models/services/utils 三层，所有页面接入真实接口，完善异步模式与错误处理规范 |
| 2026-04-xx | 初始 UI 原型完成（静态硬编码数据） |
