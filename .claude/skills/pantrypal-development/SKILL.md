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

### 删除操作（Dismissible）

InventoryPage 使用 `Dismissible` 实现左滑删除：

```dart
Dismissible(
  key: Key(item.id.toString()),
  direction: DismissDirection.endToStart,
  onDismissed: (_) async {
    try {
      await PantryService.deleteItem(id: item.id);
    } on NetworkException {
      // 处理网络异常
    }
  },
  child: ItemCard(item: item),
)
```

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
- 厨房概览 Wrap 网格（3 项 + 添加按钮）
- 管理卡片（添加物品触发 AddItemModal，成功后刷新）
- 推荐菜谱卡片（RecipeService.getSuggestions）
- 使用统计气泡（MonthlyStats）
- 常用物品排行（TopUsedItem）
- Future.wait 并行加载 4 个接口 + RefreshIndicator

### InventoryPage
- 状态筛选 Chip（全部 / 新鲜 / 即将过期 / 已过期）
- Dismissible 左滑删除
- 分页加载（PantryService.getItems + status 参数）
- 推荐菜谱卡片
- RefreshIndicator

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

## 更新记录

| 日期 | 内容 |
|------|------|
| 2026-05-07 | 前后端 API 对接全量完成：新增 models/services/utils 三层，所有页面接入真实接口，完善异步模式与错误处理规范 |
| 2026-04-xx | 初始 UI 原型完成（静态硬编码数据） |
