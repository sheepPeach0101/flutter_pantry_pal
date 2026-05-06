---
name: pantrypal-development
description: PantryPal 厨房食材库存管理 Flutter 应用的完整开发指南，涵盖项目架构、主题系统、页面结构、API 接口规范、开发路线图及编码约定。
origin: project
---

# PantryPal 开发技能

## 适用场景

在以下场景使用本技能：
- 为 PantryPal 新增页面或功能模块
- 修改或扩展现有页面 UI 和交互逻辑
- 接入后端 API 或引入状态管理
- 需要了解项目当前进度、已完成/待完成内容
- 调整主题系统（颜色、字体、深色模式）

## 项目概况

PantryPal 是一款厨房食材库存管理应用，界面主要使用**简体中文**。核心功能：
- 食材库存追踪（名称、数量、有效期）
- 使用统计与损耗分析
- 基于库存的菜谱推荐
- 用户认证（注册/登录）

**当前阶段**：UI 原型已完成，数据全部为硬编码静态内容，尚无后端集成和本地持久化。

## 技术栈

| 项 | 值 |
|---|---|
| 框架 | Flutter (Dart SDK >=2.19.0-288.0.dev <3.0.0) |
| 状态管理 | 无（基础 setState） |
| 路由 | MaterialApp.routes 命名路由 |
| 字体 | google_fonts (Inter + IBM Plex Sans) |
| 图标 | Material Icons + cupertino_icons |
| 后端 | 无（规划中） |
| 数据持久化 | 无（规划中） |

## 架构与文件结构

```
lib/
├── main.dart                      # 应用入口，路由定义
├── theme/
│   ├── index.dart                 # AppTheme 全局主题配置
│   ├── light.dart                 # Light 浅色主题颜色定义
│   └── dark.dart                  # Dark 深色主题颜色定义（未接入）
└── views/
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
'/welcome' → WelcomePage    // 初始路由
'/signup'  → SignupPage
'/login'   → LoginPage
'/home'    → MainNavigation // 底部导航容器
```

## 导航结构

`MainNavigation` 使用 `IndexedStack` + 自定义底部导航栏：

| Index | 图标 | 页面 | 说明 |
|-------|------|------|------|
| 0 | home | HomePage | 首页概览 |
| 1 | list | InventoryPage | 库存列表 |
| 2 | add (特殊按钮) | AddItemModal | 弹窗，非页面 |
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

## 页面功能详情

### WelcomePage
- 应用 Logo 占位（kitchen 图标）
- 标题 "PantryPal" + 副标题 "您的智能厨房管家"
- 箭头按钮 → `/signup`
- 文字链接 "已有账号？去登录" → `/login`

### SignupPage / LoginPage
- 邮箱 + 密码输入框
- 提交按钮 → `pushReplacementNamed('/home')`
- 底部互相跳转链接
- **待完成**：表单校验、真实认证逻辑

### HomePage
- 欢迎标题 + 库存总量
- 厨房概览 Wrap 网格（3 项 + 添加按钮）
- 管理卡片（添加物品触发 AddItemModal）
- 推荐菜谱卡片
- 使用统计气泡（已使用/损耗/价值/有效期）
- 常用物品排行列表

### InventoryPage
- 库存状态列表（物品名称 + 数量 + 过期状态）
- 推荐菜谱卡片
- **待完成**：物品编辑/删除、搜索过滤

### StatsPage
- 时间筛选（"最近 30 天"）
- 月度概览进度条
- 图表占位符（需引入 fl_chart 等库）
- 前三常用物品展示

### ProfilePage
- 用户头像 + 姓名 + 职位
- 详细信息卡片（职位/邮箱/手机/最后登录）
- 操作按钮：编辑资料、偏好设置、退出登录
- 退出登录 → `pushNamedAndRemoveUntil('/welcome')`

### AddItemModal（底部弹窗）
- 有效期选择（日期选择器占位）
- 物品信息表单（名称/数量/备注）
- 添加按钮（当前仅 pop 关闭）
- **待完成**：TextEditingController、数据保存逻辑

## API 接口规范（规划中）

### 认证
- `POST /api/auth/signup` — 用户注册
- `POST /api/auth/login` — 用户登录

### 物品管理
- `GET /api/pantry/items` — 获取库存列表
- `POST /api/pantry/items` — 新增物品
- `PUT /api/pantry/items/{id}` — 更新物品
- `DELETE /api/pantry/items/{id}` — 删除物品

### 菜谱
- `GET /api/recipes/suggestions` — 获取推荐菜谱
- `GET /api/recipes/{id}` — 获取菜谱详情

### 统计
- `GET /api/stats/monthly` — 月度概览
- `GET /api/stats/top-used` — 常用物品排行

### 公共规范
- Content-Type: `application/json`
- 认证: `Authorization: Bearer <token>`
- 错误格式: `{ "error": "错误信息" }`

## 开发路线图

### 第一阶段：逻辑走通
- 实现 AddItemModal 表单输入与数据保存
- 首页和库存页实时读取新数据
- 引入基础状态管理

### 第二阶段：内容完善
- 新增菜谱详情页（`/recipe-detail`）
- 新增编辑个人资料页（`/edit-profile`）
- 补全导航链路

### 第三阶段：体验优化
- 引入 fl_chart 实现真实统计图表
- 表单校验（邮箱格式、密码长度）
- 退出登录二次确认
- 偏好设置页面

### 第四阶段：系统集成
- 后端 API 对接
- 数据持久化（SQLite / 云端）
- 到期提醒通知
- 深色主题接入

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

### 已知问题
- `Light` 和 `Dark` 类无共同接口，切换主题需先抽象
- Dart SDK 约束为 pre-3.0，无法使用 sealed class 等 Dart 3 特性
- StatsPage 图表为 Container 占位符
- AddItemModal 输入框为静态 Container，非真实 TextField
