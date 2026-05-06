# PantryPal 后端接口需求文档 (v1.0)

本文档定义 PantryPal 移动端与后端服务交互所需的全部 API 接口规范，基于当前 UI 页面的数据需求编写。

---

## 公共规范

### 基础信息

| 项 | 值 |
|---|---|
| Base URL | `https://{host}/api` |
| Content-Type | `application/json` |
| 字符编码 | UTF-8 |

### 认证方式

除 `/api/auth/*` 外，所有接口须在 Header 中携带：

```
Authorization: Bearer <token>
```

Token 过期返回 `401 Unauthorized`，客户端应跳转至登录页。

### 统一响应格式

**成功响应**：

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**分页响应**：

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [ ... ],
    "total": 120,
    "page": 1,
    "page_size": 20
  }
}
```

**错误响应**：

```json
{
  "code": 400,
  "message": "邮箱格式不正确",
  "data": null
}
```

### 常见状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 / Token 过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 422 | 参数校验失败 |
| 500 | 服务器内部错误 |

---

## 1. 认证模块

> 对应页面：WelcomePage、SignupPage、LoginPage

### 1.1 用户注册

- **路径**: `POST /api/auth/signup`
- **说明**: 创建新用户账号并返回访问 Token
- **请求体**:

```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

- **字段校验**:
  - `email`: 必填，合法邮箱格式
  - `password`: 必填，最少 8 位

- **成功响应** (`201 Created`):

```json
{
  "code": 201,
  "message": "注册成功",
  "data": {
    "user": {
      "id": "user_001",
      "email": "user@example.com",
      "name": null,
      "avatar": null,
      "role": null,
      "phone": null,
      "created_at": "2026-04-26T10:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

- **错误响应** (`422`):

```json
{
  "code": 422,
  "message": "该邮箱已注册",
  "data": null
}
```

### 1.2 用户登录

- **路径**: `POST /api/auth/login`
- **说明**: 验证身份并获取访问 Token
- **请求体**:

```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

- **成功响应** (`200 OK`):

```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "user": {
      "id": "user_001",
      "email": "user@example.com",
      "name": "Alex Johnson",
      "avatar": null,
      "role": "厨房管家",
      "phone": null,
      "last_login_at": "2026-04-26T10:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

- **错误响应** (`401`):

```json
{
  "code": 401,
  "message": "邮箱或密码错误",
  "data": null
}
```

### 1.3 退出登录

- **路径**: `POST /api/auth/logout`
- **说明**: 使当前 Token 失效
- **请求体**: 无
- **成功响应** (`200 OK`):

```json
{
  "code": 200,
  "message": "已退出登录",
  "data": null
}
```

---

## 2. 用户信息

> 对应页面：ProfilePage

### 2.1 获取个人信息

- **路径**: `GET /api/user/profile`
- **说明**: 获取当前登录用户的完整资料
- **成功响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "user_001",
    "email": "alex@pantrypal.com",
    "name": "Alex Johnson",
    "avatar": null,
    "role": "厨房管家",
    "phone": null,
    "last_login_at": "2026-02-04T15:45:00Z",
    "created_at": "2026-01-01T08:00:00Z"
  }
}
```

### 2.2 更新个人信息

- **路径**: `PUT /api/user/profile`
- **说明**: 修改用户资料（对应"编辑资料"按钮）
- **请求体**（支持部分更新）:

```json
{
  "name": "Alex Johnson",
  "phone": "13800138000",
  "avatar": "https://cdn.example.com/avatar/001.jpg"
}
```

- **成功响应** (`200 OK`):

```json
{
  "code": 200,
  "message": "资料更新成功",
  "data": {
    "id": "user_001",
    "email": "alex@pantrypal.com",
    "name": "Alex Johnson",
    "avatar": "https://cdn.example.com/avatar/001.jpg",
    "role": "厨房管家",
    "phone": "13800138000",
    "last_login_at": "2026-02-04T15:45:00Z",
    "created_at": "2026-01-01T08:00:00Z"
  }
}
```

---

## 3. 厨房物品管理

> 对应页面：InventoryPage、HomePage（库存概览）、AddItemModal

### 3.1 获取库存列表

- **路径**: `GET /api/pantry/items`
- **说明**: 获取当前用户的所有库存物品，支持分页和筛选
- **查询参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认 1 |
| page_size | int | 否 | 每页数量，默认 20 |
| status | string | 否 | 过期状态筛选：`fresh` / `expiring` / `expired` |
| keyword | string | 否 | 按物品名称搜索 |

- **成功响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "id": "item_001",
        "name": "苹果",
        "quantity": 10,
        "unit": "个",
        "expiration_date": "2026-05-10",
        "status": "expiring",
        "status_label": "即将过期",
        "notes": "",
        "created_at": "2026-04-01T08:00:00Z"
      },
      {
        "id": "item_002",
        "name": "牛奶",
        "quantity": 2,
        "unit": "升",
        "expiration_date": "2026-05-20",
        "status": "fresh",
        "status_label": "新鲜",
        "notes": "全脂",
        "created_at": "2026-04-05T10:30:00Z"
      }
    ],
    "total": 120,
    "page": 1,
    "page_size": 20
  }
}
```

### 3.2 获取库存概览

- **路径**: `GET /api/pantry/overview`
- **说明**: 首页"厨房概览"所需的汇总数据
- **成功响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total_items": 120,
    "expiring_count": 8,
    "expired_count": 3,
    "fresh_count": 109,
    "recent_items": [
      {
        "id": "item_001",
        "name": "苹果",
        "quantity": 10,
        "unit": "个"
      }
    ]
  }
}
```

### 3.3 新增物品

- **路径**: `POST /api/pantry/items`
- **说明**: 添加新的库存物品（对应 AddItemModal）
- **请求体**:

```json
{
  "name": "牛奶",
  "quantity": 2,
  "unit": "升",
  "expiration_date": "2026-05-15",
  "notes": "全脂"
}
```

- **字段校验**:
  - `name`: 必填，最大 50 字符
  - `quantity`: 必填，正整数
  - `unit`: 必填
  - `expiration_date`: 必填，ISO 8601 日期格式（YYYY-MM-DD），不可早于今天
  - `notes`: 选填，最大 200 字符

- **成功响应** (`201 Created`):

```json
{
  "code": 201,
  "message": "添加成功",
  "data": {
    "id": "item_003",
    "name": "牛奶",
    "quantity": 2,
    "unit": "升",
    "expiration_date": "2026-05-15",
    "status": "fresh",
    "status_label": "新鲜",
    "notes": "全脂",
    "created_at": "2026-04-26T10:00:00Z"
  }
}
```

### 3.4 更新物品

- **路径**: `PUT /api/pantry/items/{id}`
- **说明**: 修改库存物品信息
- **请求体**（支持部分更新）:

```json
{
  "name": "牛奶",
  "quantity": 1,
  "unit": "升",
  "expiration_date": "2026-05-15",
  "notes": "脱脂"
}
```

- **成功响应** (`200 OK`):

```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": "item_003",
    "name": "牛奶",
    "quantity": 1,
    "unit": "升",
    "expiration_date": "2026-05-15",
    "status": "fresh",
    "status_label": "新鲜",
    "notes": "脱脂",
    "created_at": "2026-04-26T10:00:00Z"
  }
}
```

### 3.5 删除物品

- **路径**: `DELETE /api/pantry/items/{id}`
- **说明**: 从库存中移除物品
- **成功响应** (`200 OK`):

```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

- **错误响应** (`404`):

```json
{
  "code": 404,
  "message": "物品不存在",
  "data": null
}
```

---

## 4. 菜谱推荐

> 对应页面：HomePage（推荐菜谱卡片）、InventoryPage（推荐菜谱）

### 4.1 获取推荐菜谱列表

- **路径**: `GET /api/recipes/suggestions`
- **说明**: 根据当前库存食材智能推荐匹配的菜谱
- **查询参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| limit | int | 否 | 返回数量，默认 5 |

- **成功响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": "recipe_001",
      "title": "春天面条",
      "cover_image": null,
      "match_reason": "基于现有食材推荐",
      "matched_items": ["面条", "鸡蛋", "胡萝卜"],
      "missing_items": [],
      "missing_items_count": 0,
      "cooking_time_minutes": 20
    },
    {
      "id": "recipe_002",
      "title": "小炒鸡",
      "cover_image": null,
      "match_reason": "还需要 2 种食材",
      "matched_items": ["鸡肉"],
      "missing_items": ["青椒", "姜"],
      "missing_items_count": 2,
      "cooking_time_minutes": 30
    }
  ]
}
```

### 4.2 获取菜谱详情

- **路径**: `GET /api/recipes/{id}`
- **说明**: 获取单个菜谱的完整信息（对应规划中的菜谱详情页）
- **成功响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "recipe_001",
    "title": "春天面条",
    "cover_image": null,
    "description": "清爽可口的家常面条",
    "cooking_time_minutes": 20,
    "servings": 2,
    "difficulty": "简单",
    "ingredients": [
      { "name": "面条", "quantity": 200, "unit": "克", "in_pantry": true },
      { "name": "鸡蛋", "quantity": 2, "unit": "个", "in_pantry": true },
      { "name": "胡萝卜", "quantity": 1, "unit": "根", "in_pantry": true },
      { "name": "葱", "quantity": 2, "unit": "根", "in_pantry": false }
    ],
    "steps": [
      { "order": 1, "description": "烧开水，下面条煮至八分熟" },
      { "order": 2, "description": "鸡蛋打散，胡萝卜切丝" },
      { "order": 3, "description": "热锅下油，炒蛋和胡萝卜丝" },
      { "order": 4, "description": "加入面条翻炒，调味出锅" }
    ]
  }
}
```

---

## 5. 统计与报告

> 对应页面：StatsPage、HomePage（使用统计气泡）

### 5.1 获取月度概览

- **路径**: `GET /api/stats/monthly`
- **说明**: 获取本月使用比例、损耗等汇总数据
- **查询参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| days | int | 否 | 统计天数，默认 30 |

- **成功响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "period_days": 30,
    "usage_rate": 0.75,
    "used_items_count": 50,
    "waste_count": 12,
    "waste_growth_rate": 0.05,
    "total_value": 450.00,
    "currency": "CNY",
    "avg_shelf_life_days": 14,
    "shelf_life_improvement_days": 2,
    "daily_usage": [
      { "date": "2026-04-01", "count": 3 },
      { "date": "2026-04-02", "count": 5 }
    ]
  }
}
```

### 5.2 获取常用物品排行

- **路径**: `GET /api/stats/top-used`
- **说明**: 获取使用频率最高的物品列表
- **查询参数**:

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| limit | int | 否 | 返回数量，默认 10 |

- **成功响应**:

```json
{
  "code": 200,
  "message": "success",
  "data": [
    { "name": "苹果", "usage_count": 50, "icon": "restaurant_rounded" },
    { "name": "牛奶", "usage_count": 30, "icon": null },
    { "name": "鸡蛋", "usage_count": 25, "icon": null },
    { "name": "面包", "usage_count": 20, "icon": null },
    { "name": "米饭", "usage_count": 18, "icon": "grain_rounded" },
    { "name": "胡萝卜", "usage_count": 15, "icon": "spa_rounded" }
  ]
}
```

---

## 6. 接口与页面映射

| 页面 | 依赖接口 |
|------|----------|
| SignupPage | `POST /api/auth/signup` |
| LoginPage | `POST /api/auth/login` |
| HomePage - 欢迎标题 | `GET /api/user/profile` |
| HomePage - 厨房概览 | `GET /api/pantry/overview` |
| HomePage - 推荐菜谱 | `GET /api/recipes/suggestions` |
| HomePage - 使用统计 | `GET /api/stats/monthly` |
| HomePage - 常用物品 | `GET /api/stats/top-used` |
| InventoryPage - 库存列表 | `GET /api/pantry/items` |
| InventoryPage - 推荐菜谱 | `GET /api/recipes/suggestions` |
| AddItemModal | `POST /api/pantry/items` |
| StatsPage - 月度概览 | `GET /api/stats/monthly` |
| StatsPage - 常用物品 | `GET /api/stats/top-used` |
| ProfilePage - 个人信息 | `GET /api/user/profile` |
| ProfilePage - 编辑资料 | `PUT /api/user/profile` |
| ProfilePage - 退出登录 | `POST /api/auth/logout` |
| 菜谱详情页（规划中） | `GET /api/recipes/{id}` |
| 物品编辑（规划中） | `PUT /api/pantry/items/{id}` |
| 物品删除（规划中） | `DELETE /api/pantry/items/{id}` |

---

## 7. 接入优先级

基于开发路线图，建议按以下顺序接入：

| 优先级 | 接口 | 理由 |
|--------|------|------|
| P0 | `POST /api/auth/signup`、`POST /api/auth/login` | 认证是所有功能的前提 |
| P0 | `POST /api/pantry/items`、`GET /api/pantry/items` | 核心功能：添加和查看库存 |
| P1 | `GET /api/pantry/overview` | 首页数据展示 |
| P1 | `PUT /api/pantry/items/{id}`、`DELETE /api/pantry/items/{id}` | 库存编辑删除 |
| P1 | `GET /api/user/profile`、`PUT /api/user/profile` | 个人中心数据 |
| P2 | `GET /api/stats/monthly`、`GET /api/stats/top-used` | 统计功能 |
| P2 | `GET /api/recipes/suggestions`、`GET /api/recipes/{id}` | 菜谱推荐功能 |
| P3 | `POST /api/auth/logout` | 退出登录 |
