# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 提供在此代码库中工作的指导。

## 项目概述

PantryPal 是一款 Flutter 厨房食材库存管理应用，界面主要使用简体中文。功能包括：追踪食材、管理有效期、统计使用情况、以及根据库存推荐食谱。

## 常用命令

```bash
# 运行应用
flutter run

# 在指定平台运行
flutter run -d windows
flutter run -d chrome

# 获取依赖
flutter pub get

# 运行测试
flutter test

# 代码分析
dart analyze

# 格式化代码
dart format .
```

## 架构说明

**无状态管理库** — 应用使用基础的 `StatefulWidget` / `StatelessWidget` 配合 `setState()`，未引入 BLoC、Riverpod 或 Provider。

**无后端集成** — 所有数据目前为硬编码/静态数据，无 API 调用，无本地数据库。

**路由**：在 `lib/main.dart` 的 `MaterialApp.routes` 中定义命名路由：
- `/welcome` → `WelcomePage`（初始路由）
- `/signup` → `SignupPage`
- `/login` → `LoginPage`
- `/home` → `MainNavigation`（底部导航容器）

**导航**：`lib/views/navigation_wrapper.dart` 中的 `MainNavigation` 使用 `IndexedStack` 配合自定义底部导航栏（5 个标签：首页、库存、新增、统计、设置）。第 3 个标签"新增"（index 2）会触发 `showModalBottomSheet`，而非跳转页面。

## 主题系统

`lib/theme/index.dart` — `AppTheme` 类，包含静态字段 `currentColors`（当前硬编码为 `Light()`）。深色主题类已存在（`lib/theme/dark.dart`），但尚未接入。

颜色 token 使用 `ih_` 前缀（如 `ih_accent`、`ih_bg`、`ih_surface`、`ih_text`）。`Light` 和 `Dark` 类定义了相同的颜色字段，但未抽象为共同接口或抽象类。

字体使用 `google_fonts` 包，主要为 `Inter` 和 `IBM Plex Sans`。

## SDK 约束

Dart SDK `>=2.19.0-288.0.dev <3.0.0` — 这是 Dart 3 之前的版本约束。除非更新约束，否则无法使用 Dart 3 特性（sealed classes、records、pattern matching）。
