---
name: Flutter API integration patterns
description: 前端 API 对接完成后确立的关键架构模式与踩坑，2026-05-07
type: project
---

前后端 API 对接（2026-05-07）完成后，Flutter 前端确立了以下架构决策：

**三层架构**：Models → Services → Views，不引入状态管理库。

**单例模式**：ApiClient、TokenManager、AuthNotifier 均为 Singleton，跨页面共享状态。

**401 处理在视图层**：ApiClient 只抛出 UnauthorizedException，不主动跳转，由各页面 catch 后执行 clearAuth() + Navigator。

**mounted 检查**：每次 await 之后，操作 context/setState/Navigator 前必须 `if (!mounted) return;`。clearAuth/logout 本身是 async，await 后需二次检查。

**SnackBar 跨 pop 问题**：Navigator.pop 之前必须先捕获 `ScaffoldMessenger.of(context)`，pop 后再调用 showSnackBar。

**Why:** 这些模式在 code review 阶段被发现并修复，属于 Flutter 异步+导航的常见陷阱。

**How to apply:** 每次新增涉及 async + Navigator 的页面时，检查以上三点。
