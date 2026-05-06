# PantryPal 补全计划 - 第一阶段

本计划旨在解决 [project_status_report.md](file:///C:/Users/Administrator/.gemini/antigravity/brain/c54ca4ff-4677-48ba-be20-b37c682ddaa2/project_status_report.md) 中识别出的核心缺失项，重点在于让应用从“纯 UI”转向“可交互”。

## 拟议更改

### 1. 核心导航与业务逻辑 (Navigation Wrapper)
- #### [MODIFY] [navigation_wrapper.dart](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/navigation_wrapper.dart)
    - 实现 [AddItemModal](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/navigation_wrapper.dart#112-275) 的表单输入监听（TextEditingController）。
    - 修改“添加”按钮逻辑，将输入的数据传递给状态管理或简单的内存列表（待后续持久化）。
    - 增加添加成功后的提示（SnackBar）。

### 2. 新增页面 (New Pages)
- #### [NEW] [recipe_detail.dart](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/recipe_detail.dart)
    - 创建菜谱详情页面，展示食材、步骤、烹饪时间等信息。
    - 在 [main.dart](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/main.dart) 中注册路由 `/recipe-detail`。
- #### [NEW] [edit_profile.dart](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/edit_profile.dart)
    - 创建编辑个人资料页面，支持修改头像、昵称、邮箱等。
    - 在 [main.dart](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/main.dart) 中注册路由 `/edit-profile`。

### 3. 主导航关联
- #### [MODIFY] [home.dart](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/home.dart)
    - 将“查看菜谱”按钮点击事件链接至 `/recipe-detail`。
- #### [MODIFY] [profile.dart](file:///e:/workspace/PantryPal/code/flutter_pantry_pal/lib/views/profile.dart)
    - 将“编辑资料”按钮点击事件链接至 `/edit-profile`。

---

## 验证计划

### 自动测试
- (暂无，本项目目前以 UI 交互验证为主)

### 手动验证
1. **添加功能**: 打开“新增物品”弹窗，填写内容并点击“添加”，验证弹窗是否关闭并显示“添加成功”提示。
2. **菜谱跳转**: 在首页点击“查看菜谱”，验证是否跳转至新的详情页。
3. **编辑资料跳转**: 在个人中心点击“编辑资料”，验证是否跳转至编辑页。
