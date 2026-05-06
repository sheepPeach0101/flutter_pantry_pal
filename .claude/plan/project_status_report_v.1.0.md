# PantryPal 项目现状整理与补充建议

本文档详细说明了 PantryPal 厨房助手项目的当前进度，并列出了需要进一步补充的功能、页面及交互细节。

---

## 1. 已完成内容概览

目前应用已完成主要页面的 UI 开发及初步路由导航逻辑：

- **身份验证模块**:
  - [WelcomePage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/welcome.dart#5-11): 欢迎页，支持跳转至注册或登录。
  - [SignupPage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/signup.dart#5-156): 注册页，包含邮箱、密码输入及跳转至登录。
  - [LoginPage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/login.dart#5-156): 登录页，包含邮箱、密码输入及跳转至注册。
- **主应用模块**:
  - [MainNavigation](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/navigation_wrapper.dart#9-15): 底部导航容器及全局 Add 按钮弹窗逻辑。
  - [HomePage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/home.dart#6-396): 首页概览，包含库存统计、管理项、推荐菜谱、统计简述。
  - [InventoryPage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/inventory.dart#5-160): 库存列表页，显示物品名称、数量及过期状态。
  - [StatsPage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/stats.dart#5-266): 统计页，包含月度进度条、损耗分析图表占位符。
  - [ProfilePage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/profile.dart#5-187): 个人中心，显示用户信息、详细资料及操作按钮（编辑、偏好、退出）。
- **交互组件**:
  - [AddItemModal](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/navigation_wrapper.dart#112-275): “新增物品录入”弹窗 UI。

---

## 2. 交互细节与功能补充

### A. 弹窗与模态框 (Modals)
目前大部分弹窗仅有 UI 框架，缺乏实际业务逻辑：
- **新增物品 (AddItemModal)**: 需要点击“添加”后执行实际的数据保存逻辑（目前仅为 `pop`）。
- **退出登录确认**: 建议增加二次确认弹窗，防止用户误触退出按钮。
- **偏好设置 (Preferences)**: 个人中心中“偏好设置”按钮目前无反应，需设计并实现偏好设置弹窗或页面（如：语言切换、通知设置等）。
- **物品编辑与删除**: 在库存列表中点击物品应弹出“修改名称/数量”或“删除”的操作框。

### B. 缺失的页面 (Missing Pages)
- **菜谱详情页 (Recipe Detail)**: 首页和库存页都有“查看菜谱”链接，但目前没有详情页来显示食材清单和步骤。
- **编辑个人资料 (Edit Profile)**: 个人中心的“编辑资料”按钮需要跳转至独立的编辑页面。
- **搜索页 (Search)**: 首页和个人中心均有搜索图标，但点击后没有对应的搜索过滤页面。
- **全部常用物品列表 (View All)**: 首页的“常用物品”部分有“查看全部”按钮，需对应一个完整的常用历史列表页。

### C. 核心逻辑补全
- **数据持久化**: 当前所有数据（库存数量、物品名称）均为静态硬编码，需要引入 SQLite、Shared Preferences 或云端数据库进行保存。
- **表单效验 (Form Validation)**: 登录和注册页面需要增加邮箱格式检查、密码长度检查及错误提示。
- **统计图表**: [StatsPage](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/stats.dart#5-266) 目前使用的是 Container 占位符，需要引入 `fl_chart` 等库实现真正的折线图或柱状图。
- **到期提醒**: 需要实现本地通知功能，当物品即将过期时主动提醒用户。

---

## 3. 建议开发路线图

1. **第一阶段 (逻辑走通)**: 实现 [AddItemModal](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/navigation_wrapper.dart#112-275) 的数据保存，并让首页和库存页能实时读取新数据。
2. **第二阶段 (内容完善)**: 编写“菜谱详情页”和“编辑个人资料”页面，补全导航链路。
3. **第三阶段 (体验优化)**: 引入真实的统计图表，增加表单校验和退出确认等细节交互。
4. **第四阶段 (系统集成)**: 增加到期提醒通知及数据备份功能。
