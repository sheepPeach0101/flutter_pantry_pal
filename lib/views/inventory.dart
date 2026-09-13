import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/models/api_response.dart';
import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/models/recipe.dart';
import 'package:PantryPal/services/pantry_service.dart';
import 'package:PantryPal/services/recipe_service.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:PantryPal/widgets/edit_item_modal.dart';
import 'package:PantryPal/widgets/item_action_sheet.dart';
import 'package:PantryPal/widgets/use_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => InventoryPageState();
}

class InventoryPageState extends State<InventoryPage> {
  final _pantryService = PantryService();
  final _recipeService = RecipeService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedStatus;

  // #106: 搜索模式状态变量
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  String? _searchKeyword;

  List<PantryItem> _items = [];
  int _total = 0;
  List<RecipeSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // #111: 资源释放
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // #108: 修改 _loadData()，将 _searchKeyword 传入 getItems
  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _pantryService.getItems(
          page: 1,
          pageSize: 50,
          status: _selectedStatus,
          keyword: _searchKeyword, // #108: 传入关键词
        ),
        _recipeService.getSuggestions(limit: 2),
      ]);

      final paginated = results[0] as PaginatedData<PantryItem>;
      if (mounted) {
        setState(() {
          _items = paginated.items;
          _total = paginated.total;
          _suggestions = results[1] as List<RecipeSuggestion>;
          _isLoading = false;
        });
      }
    } on UnauthorizedException {
      if (mounted) {
        await AuthNotifier.instance.clearAuth();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, '/welcome', (route) => false);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> refresh() => _loadData();

  Future<void> applyFilter(String? status) async {
    setState(() => _selectedStatus = status);
    await _loadData();
  }

  // #106/#107: applySearch 更新，进入搜索模式并预填关键词
  Future<void> applySearch(String keyword,
      {String? autoShowActionSheetForItem}) async {
    setState(() {
      _isSearchMode = true;
      _searchKeyword = keyword;
      _selectedStatus = null;
    });
    _searchController.text = keyword;
    await _loadData();
    if (!mounted) return;
    if (autoShowActionSheetForItem != null) {
      // 使用 addPostFrameCallback 确保列表渲染完成后再弹出 ActionSheet，
      // 符合 SKILL.md 6.2 两步操作延迟规范。
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

  // #109: 过期警告弹窗
  Future<bool> _showExpiredWarning(PantryItem item, String action) async {
    final actionLabel = action == 'edit' ? '编辑' : '使用';
    final dateStr =
        DateFormat('yyyy-MM-dd').format(item.expirationDate);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('物品已过期'),
        content: Text(
          '「${item.name}」已于 $dateStr 过期，确认继续$actionLabel？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '继续$actionLabel',
              style: const TextStyle(color: Color(0xFFE57373)),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  // #110: 修改 _showActionSheet，对 edit/use 增加过期拦截
  Future<void> _showActionSheet(PantryItem item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemActionSheet(item: item),
    );

    if (!mounted) return;

    if (action == 'edit') {
      // #110: 过期拦截 - edit
      if (item.status == 'expired') {
        final confirmed = await _showExpiredWarning(item, 'edit');
        if (!mounted) return;
        if (!confirmed) return;
      }
      await _showEditModal(item);
    } else if (action == 'use') {
      // #110: 过期拦截 - use
      if (item.status == 'expired') {
        final confirmed = await _showExpiredWarning(item, 'use');
        if (!mounted) return;
        if (!confirmed) return;
      }
      await _showUseDialog(item);
    } else if (action == 'delete') {
      await _confirmAndDelete(item);
    }
  }

  Future<void> _showEditModal(PantryItem item) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EditItemModal(item: item),
    );
    if (result == true && mounted) {
      await _loadData();
    }
  }

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

  Future<void> _confirmAndDelete(PantryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.name}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _pantryService.deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('删除成功')));
        await _loadData();
      }
    } on UnauthorizedException {
      if (!mounted) return;
      await AuthNotifier.instance.clearAuth();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on NetworkException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _onFilterChanged(String? status) {
    setState(() => _selectedStatus = status);
    _loadData();
  }

  // #107: 进入搜索模式
  void _enterSearchMode() {
    setState(() => _isSearchMode = true);
    // autofocus: true 由 TextField 自动处理键盘唤起
  }

  // #107: 退出搜索模式（取消按钮）
  void _exitSearchMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearchMode = false;
      _searchKeyword = null;
    });
    _searchController.clear();
    _loadData(); // 关键词清空后重新加载，恢复当前 _selectedStatus 筛选
  }

  // #107: 清除输入内容（保留聚焦）
  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchKeyword = null);
    _loadData(); // 清空关键词后重载，恢复全量（当前筛选状态）
    // 不调用 unfocus()，保持搜索框聚焦，让用户可继续输入
  }

  // #107: 键盘搜索键提交
  void _onSearchSubmitted(String keyword) {
    final trimmed = keyword.trim();
    setState(() {
      _searchKeyword = trimmed.isEmpty ? null : trimmed;
      _selectedStatus = null; // 强制切换到"全部"分类
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _loadData, child: const Text('重试')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _buildContent(),
                  ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFilterRow(),
          const SizedBox(height: 16),
          _buildSectionTitle("库存状态 ($_total)"),
          const SizedBox(height: 12),
          _buildStockStatusList(),
          const SizedBox(height: 32),
          _buildSectionTitle("推荐菜谱"),
          const SizedBox(height: 12),
          ..._suggestions.map((s) {
            final subtitle = s.missingItemsCount == 0
                ? '基于现有食材推荐'
                : '还需要 ${s.missingItemsCount} 种食材';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecipeCard(s.title, subtitle),
            );
          }),
          if (_suggestions.isEmpty)
            _buildRecipeCard("暂无推荐", "请先添加库存物品"),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // #107: 修改 _buildHeader()，支持默认态与搜索模式态切换
  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _isSearchMode
            ? _buildSearchModeHeader(key: const ValueKey('search'))
            : _buildDefaultHeader(key: const ValueKey('default')),
      ),
    );
  }

  // #107: 默认态 Header（标题 + 搜索图标按钮）
  Widget _buildDefaultHeader({Key? key}) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "厨房物品",
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        Semantics(
          label: "搜索厨房物品",
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              splashColor: const Color(0x1AC67A52),
              onTap: _enterSearchMode,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.search_rounded,
                  color: AppTheme.currentColors.ih_text_muted,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // #107: 搜索模式态 Header（搜索框 + 取消按钮）
  Widget _buildSearchModeHeader({Key? key}) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildSearchInputField()),
        const SizedBox(width: 12),
        _buildCancelButton(),
      ],
    );
  }

  // #107: 搜索输入框（聚焦态视觉语言复用首页搜索栏）
  Widget _buildSearchInputField() {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {}); // 触发重建以更新边框和图标颜色
      },
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.currentColors.ih_surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFocus
                    ? AppTheme.currentColors.ih_accent
                    : AppTheme.currentColors.ih_border,
                width: hasFocus ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasFocus
                      ? AppTheme.currentColors.ih_accent.withValues(alpha: 0.12)
                      : const Color(0x0A000000), // 纯黑 4%
                  blurRadius: hasFocus ? 8 : 4,
                  offset: Offset(0, hasFocus ? 2 : 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: hasFocus
                        ? AppTheme.currentColors.ih_accent
                        : AppTheme.currentColors.ih_text_muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      label: "搜索厨房物品",
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.currentColors.ih_text,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: "搜索厨房物品",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.currentColors.ih_text_muted,
                          ),
                        ),
                        onSubmitted: _onSearchSubmitted,
                        onChanged: (value) {
                          setState(() {}); // 控制清除按钮显示/隐藏
                        },
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Semantics(
                      label: "清除搜索内容",
                      button: true,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: _clearSearch,
                          child: Padding(
                            padding: const EdgeInsets.all(13),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppTheme.currentColors.ih_text_muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // #107: 取消按钮（InkWell + Padding 44pt 触控区域）
  Widget _buildCancelButton() {
    return Semantics(
      label: "取消搜索",
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: _exitSearchMode,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
          child: Text(
            "取消",
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.currentColors.ih_accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = [
      {'label': '全部', 'value': null},
      {'label': '新鲜', 'value': 'fresh'},
      {'label': '即将过期', 'value': 'expiring'},
      {'label': '已过期', 'value': 'expired'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStatus == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onFilterChanged(f['value']),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.currentColors.ih_accent
                      : AppTheme.currentColors.ih_surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  f['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.currentColors.ih_text_secondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.currentColors.ih_text_muted));
  }

  Widget _buildStockStatusList() {
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            _searchKeyword != null && _searchKeyword!.isNotEmpty
                ? "未找到相关物品"
                : "暂无物品",
            style: GoogleFonts.inter(
                fontSize: 14, color: AppTheme.currentColors.ih_text_muted),
          ),
        ),
      );
    }

    return Column(
      children: _items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStockItem(item),
        );
      }).toList(),
    );
  }

  Widget _buildStockItem(PantryItem item) {
    return Material(
      color: AppTheme.currentColors.ih_surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showActionSheet(item),
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.currentColors.ih_accent.withValues(alpha: 0.08),
        highlightColor: AppTheme.currentColors.ih_surface_warm,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.currentColors.ih_text,
                      ),
                    ),
                    Text(
                      "${item.quantity} ${item.unit} • ${item.statusLabel}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.currentColors.ih_text_secondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(item.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'fresh':
        color = Colors.green;
        break;
      case 'expiring':
        color = Colors.orange;
        break;
      case 'expired':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildRecipeCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.currentColors.ih_text_secondary)),
        ],
      ),
    );
  }
}
