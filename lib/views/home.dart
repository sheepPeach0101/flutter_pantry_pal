import 'dart:async';

import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/models/api_response.dart';
import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/models/stats.dart';
import 'package:PantryPal/models/recipe.dart';
import 'package:PantryPal/services/pantry_service.dart';
import 'package:PantryPal/services/stats_service.dart';
import 'package:PantryPal/services/recipe_service.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:PantryPal/views/navigation_wrapper.dart';
import 'package:PantryPal/widgets/edit_item_modal.dart';
import 'package:PantryPal/widgets/item_action_sheet.dart';
import 'package:PantryPal/widgets/use_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.onNavigateToInventory,
    this.onSwitchTab,
    this.onSwitchToInventoryWithSearch,
  });

  final void Function(String? filter)? onNavigateToInventory;
  final void Function(int index)? onSwitchTab;
  final void Function(String keyword, {String? targetItemName})?
      onSwitchToInventoryWithSearch;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _pantryService = PantryService();
  final _statsService = StatsService();
  final _recipeService = RecipeService();

  bool _isLoading = false;
  String? _errorMessage;

  PantryOverview? _overview;
  List<TopUsedItem> _topItems = [];
  List<RecipeSuggestion> _suggestions = [];

  // ——— 搜索相关状态 ———
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<PantryItem> _searchResults = [];
  /// 是否正在执行搜索请求（显示加载进度条）
  bool _isSearchLoading = false;
  /// 是否显示搜索浮层（有关键词输入时为 true）
  bool _isSearching = false;
  /// 当前搜索关键词（与实际发起请求时的关键词一致，用于高亮匹配文字）
  String _searchKeyword = '';
  /// 搜索框是否聚焦（控制边框/图标颜色）
  bool _isSearchFocused = false;
  /// 防抖 Timer
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode
      ..removeListener(_onSearchFocusChanged)
      ..dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 搜索框焦点变化监听：更新聚焦态，再次聚焦时复用缓存结果（S-2b）。
  void _onSearchFocusChanged() {
    final focused = _searchFocusNode.hasFocus;
    setState(() {
      _isSearchFocused = focused;
      if (focused &&
          _searchController.text.isNotEmpty &&
          _searchResults.isNotEmpty) {
        // 再次聚焦且有缓存结果时，直接展示浮层，无需重新请求（S-2b）
        _isSearching = true;
      }
    });
  }

  Future<void> refresh() => _loadData();

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _pantryService.getOverview(),
        _statsService.getTopUsed(limit: 4),
        _recipeService.getSuggestions(limit: 3),
      ]);

      if (mounted) {
        setState(() {
          _overview = results[0] as PantryOverview;
          _topItems = results[1] as List<TopUsedItem>;
          _suggestions = results[2] as List<RecipeSuggestion>;
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
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  // ——— 搜索防抖方法 ———

  /// 搜索框内容变化回调，300ms 防抖后调用 API。
  /// 空关键词时立即清空结果并隐藏浮层；
  /// 非空时展示加载态，防抖结束后请求数据。
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
    // 立即切换到加载态，给用户即时反馈
    setState(() {
      _isSearchLoading = true;
      _isSearching = true;
    });
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final paged =
            await _pantryService.getItems(keyword: keyword, pageSize: 50);
        if (!mounted) return;
        // 竞态保护：防抖触发后用户可能继续输入，若请求关键词与当前输入不一致则丢弃本次结果
        if (keyword != _searchController.text) return;
        setState(() {
          _searchKeyword = keyword;
          _searchResults = paged.items;
          _isSearchLoading = false;
        });
      } on UnauthorizedException {
        if (!mounted) return;
        await AuthNotifier.instance.clearAuth();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
      } catch (_) {
        // 搜索异常时优雅降级：清空结果、隐藏加载态，不影响主页正常使用
        if (!mounted) return;
        setState(() {
          _searchResults = [];
          _isSearchLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _buildContent(),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage!,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.currentColors.ih_text_secondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('重试')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // 使用 Stack 将浮层叠加在页面内容之上。
    // GestureDetector（translucent）捕获浮层外的点击，收起键盘并关闭浮层，但不清空内容。
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // 点击浮层外区域：收起键盘，隐藏浮层，保留搜索内容（S-2b）
        // 条件用 _isSearching：键盘 search 键按下后 _isSearchFocused=false 但浮层仍显示，
        // 此时点击空白处应仍能关闭浮层
        if (_isSearching) {
          _searchFocusNode.unfocus();
          // _isSearchFocused 会由 FocusNode listener 自动更新
          // 浮层关闭但内容不清空，下次聚焦可复用缓存结果
          setState(() {
            _isSearching = false;
          });
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 16), // spacing_md
            // 搜索框 + 浮层放在同一局部 Stack 中，浮层相对于搜索框底边精准定位。
            // clipBehavior: Clip.none 允许浮层溢出，避免硬编码页面级偏移量（问题3修复）。
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildSearchBar(),
                if (_isSearching || _isSearchLoading)
                  Positioned(
                    // 搜索框高度 48pt + 4pt gap，与搜索框底边保持 spacing_xs 间距
                    top: 48 + 4,
                    left: 0,
                    right: 0,
                    child: _buildSearchResults(),
                  ),
              ],
            ),
            const SizedBox(height: 16), // spacing_md
            _buildSectionTitle("您的厨房概览"),
            const SizedBox(height: 12),
            _buildOverviewRow(),
            _buildExpiredAlert(),
            const SizedBox(height: 32),
            _buildManageCard(context),
            const SizedBox(height: 32),
            _buildTopItemsHeader(),
            const SizedBox(height: 12),
            _buildTopItemsList(),
            const SizedBox(height: 32),
            _buildSectionTitle("推荐菜谱"),
            const SizedBox(height: 12),
            ..._buildRecipeCards(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ——— 搜索栏 Widget ———

  /// 搜索框组件（HomeSearchBar）。
  /// 设计稿 v1.1：ih_surface 背景，48pt 高，16pt 圆角；
  /// 聚焦时 ih_accent 边框（1.5pt）+ 图标变橙 + 暖橙色阴影。
  Widget _buildSearchBar() {
    final colors = AppTheme.currentColors;
    final isFocused = _isSearchFocused;
    final hasText = _searchController.text.isNotEmpty;

    // 阴影：默认态纯黑 4%；聚焦态 ih_accent 暖橙 12%（设计稿色值权威格式）
    final shadow = isFocused
        ? const BoxShadow(
            color: Color(0x1FC67A52), // ih_accent 12%
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        : const BoxShadow(
            color: Color(0x0A000000), // 纯黑 4%
            blurRadius: 4,
            offset: Offset(0, 1),
          );

    return Semantics(
      label: '搜索厨房物品',
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colors.ih_surface,
          borderRadius: BorderRadius.circular(16), // radius_lg
          border: Border.all(
            color: isFocused ? colors.ih_accent : colors.ih_border,
            width: isFocused ? 1.5 : 1.0,
          ),
          boxShadow: [shadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 12),
            // 搜索图标：聚焦态变橙
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isFocused ? colors.ih_accent : colors.ih_text_muted,
            ),
            const SizedBox(width: 8),
            // 搜索输入框
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: colors.ih_text,
                ),
                decoration: InputDecoration(
                  hintText: '搜索厨房物品',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: colors.ih_text_muted,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: (_) {
                  // 键盘搜索键：收起键盘但保留浮层（S-2b 设计决策）
                  _searchFocusNode.unfocus();
                  // 注意：不修改 _isSearching，浮层继续显示当前结果
                },
              ),
            ),
            // 清除按钮：有输入内容时显示（44×44pt 点击区域，圆形 Ripple）
            if (hasText) ...[
              Semantics(
                label: '清除搜索内容',
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      _searchController.clear();
                      _onSearchChanged('');
                      // 保留聚焦状态，让用户可直接继续输入新关键词
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(13), // 图标 18pt + padding 13×2 = 44pt touch target
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF9A9A9A), // ih_text_muted
                      ),
                    ),
                  ),
                ),
              ),
            ] else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ——— 搜索结果浮层 Widget ———

  /// 搜索结果浮层（SearchResultOverlay）。
  /// 最多展示 4 条结果；结果数 > 4 时底部显示「查看全部结果」按钮。
  /// 无结果时展示空结果占位（manage_search_rounded 图标 + 双行文案）。
  Widget _buildSearchResults() {
    final colors = AppTheme.currentColors;
    final keyword = _searchKeyword;

    // 加载中：在搜索框底边展示细线进度条（参考设计稿 S-5）
    if (_isSearchLoading && _searchResults.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colors.ih_surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000), // 纯黑 10%
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LinearProgressIndicator(
          minHeight: 3,
          valueColor:
              AlwaysStoppedAnimation<Color>(colors.ih_accent),
          backgroundColor:
              colors.ih_border,
        ),
      );
    }

    // 空结果态（有关键词但无匹配）
    if (!_isSearchLoading && _isSearching && _searchResults.isEmpty && keyword.isNotEmpty) {
      return Semantics(
        label: '没有找到与"$keyword"相关的物品',
        child: Container(
          decoration: BoxDecoration(
            color: colors.ih_surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.manage_search_rounded,
                  size: 36,
                  color: colors.ih_text_muted,
                ),
                const SizedBox(height: 10),
                Text(
                  '没有找到相关物品',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.ih_text_secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '试试其他关键词，或前往厨房物品页查看',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colors.ih_text_muted,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 有结果：最多展示 4 条，超过 4 条时显示「查看全部结果」按钮
    final displayItems = _searchResults.take(4).toList();
    final hasMore = _searchResults.length > 4;

    return Container(
      decoration: BoxDecoration(
        color: colors.ih_surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 结果列表
          ...displayItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == displayItems.length - 1;
            // 若有「更多」按钮，最后一项底部圆角为 0（与按钮无缝拼接，设计稿 S-7）
            // 若无「更多」按钮，最后一项底部圆角跟随容器（16pt，clipBehavior 已处理）
            // TODO(问题6): suppressBottomRadius 逻辑待后续圆角 token 化时统一处理
            final showDivider = !isLast || hasMore;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSearchResultItem(item, keyword, isLast && hasMore),
                if (showDivider)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: colors.ih_border,
                    ),
                  ),
              ],
            );
          }),
          // 「查看全部结果」按钮（结果数 > 4 时显示）
          if (hasMore) _buildSearchMoreButton(keyword),
        ],
      ),
    );
  }

  /// 单条搜索结果项（物品名称 + 关键词高亮 + 状态标签）。
  /// [suppressBottomRadius]：是否抑制底部圆角（接「更多」按钮时使用）。
  Widget _buildSearchResultItem(
      PantryItem item, String keyword, bool suppressBottomRadius) {
    final colors = AppTheme.currentColors;
    final borderRadius = suppressBottomRadius
        ? const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          )
        : BorderRadius.zero;

    return Semantics(
      label: '${item.name}，状态：${item.statusLabel}，点击查看详情',
      button: true,
      child: Material(
        color: colors.ih_surface,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: () {
            // 点击结果项：跳转 InventoryPage 并自动弹出对应物品 ActionSheet
            widget.onSwitchToInventoryWithSearch?.call(
              item.name,
              targetItemName: item.name,
            );
            // 关闭浮层
            setState(() {
              _isSearching = false;
              _isSearchFocused = false;
            });
            FocusScope.of(context).unfocus();
          },
          borderRadius: borderRadius,
          // Ripple 色：ih_accent_soft 约 19% 透明度（设计稿权威色值）
          splashColor: const Color(0x30E09B76),
          highlightColor: const Color(0x1AE09B76),
          child: SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 物品名称（含关键词高亮）
                  Expanded(
                    child: _buildHighlightedName(item.name, keyword),
                  ),
                  // 状态标签（非 fresh 时显示）
                  if (item.status != 'fresh') ...[
                    const SizedBox(width: 8),
                    _buildStatusBadge(item.status),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 关键词高亮文本（Text.rich + TextSpan）。
  /// 匹配部分使用 ih_accent（w700），其余部分使用 ih_text（w500）。
  Widget _buildHighlightedName(String name, String keyword) {
    final colors = AppTheme.currentColors;
    final normalStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: colors.ih_text,
    );
    final highlightStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: colors.ih_accent,
    );

    if (keyword.isEmpty) {
      return Text(name, style: normalStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final lowerName = name.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    final index = lowerName.indexOf(lowerKeyword);

    if (index < 0) {
      return Text(name, style: normalStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return Text.rich(
      TextSpan(
        children: [
          if (index > 0)
            TextSpan(
                text: name.substring(0, index), style: normalStyle),
          TextSpan(
            text: name.substring(index, index + keyword.length),
            style: highlightStyle,
          ),
          if (index + keyword.length < name.length)
            TextSpan(
                text: name.substring(index + keyword.length),
                style: normalStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 状态徽章（expiring / expired / used_up）。
  /// 颜色直接复用 InventoryPage 已有的状态徽章配色方案。
  /// TODO(问题8): 徽章颜色待后续统一 token 化（与 InventoryPage 共享同一色值定义）
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'expiring':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        label = '即将过期';
      case 'expired':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        label = '已过期';
      case 'used_up':
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        label = '已用完';
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// 「查看全部结果」按钮（搜索结果 > 4 条时显示）。
  Widget _buildSearchMoreButton(String keyword) {
    final colors = AppTheme.currentColors;
    return Semantics(
      label: '查看全部搜索结果',
      button: true,
      child: Material(
        color: colors.ih_surface_warm,
        // 顶部圆角 0pt（接上方分割线），底部圆角 16pt（与浮层底部一致，设计稿 S-7）
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // 跳转 InventoryPage 展示完整搜索结果
            widget.onSwitchToInventoryWithSearch?.call(keyword);
            setState(() {
              _isSearching = false;
              _isSearchFocused = false;
            });
            FocusScope.of(context).unfocus();
          },
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          splashColor: const Color(0x1FC67A52), // ih_accent 12%
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 14,
                  color: colors.ih_accent,
                ),
                const SizedBox(width: 6),
                Text(
                  '查看全部结果',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.ih_accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userName =
        AuthNotifier.instance.currentUser?.name ?? 'Welcome to';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text,
              ),
            ),
            Text(
              "库存总量: ${_overview?.totalItems ?? 0}",
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: AppTheme.currentColors.ih_text_secondary,
              ),
            ),
          ],
        ),
        Icon(
          Icons.account_circle_rounded,
          size: 32,
          color: AppTheme.currentColors.ih_text_muted,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.currentColors.ih_text,
      ),
    );
  }

  Widget _buildOverviewRow() {
    final ov = _overview;

    String clampCount(int n) => n >= 1000 ? '999+' : '$n';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _OverviewCard(
          label: '新鲜',
          count: clampCount(ov?.freshCount ?? 0),
          cardColor: const Color(0xFFE8F5E9),
          rippleColor: Colors.green,
          status: 'fresh',
          onTap: () => widget.onNavigateToInventory?.call('fresh'),
        ),
        _OverviewCard(
          label: '即将过期',
          count: clampCount(ov?.expiringCount ?? 0),
          cardColor: const Color(0xFFFFF3E0),
          rippleColor: Colors.orange,
          status: 'expiring',
          onTap: () => widget.onNavigateToInventory?.call('expiring'),
        ),
        _OverviewCard(
          label: '已过期',
          count: clampCount(ov?.expiredCount ?? 0),
          cardColor: const Color(0xFFFFEBEE),
          rippleColor: Colors.red,
          status: 'expired',
          onTap: () => widget.onNavigateToInventory?.call('expired'),
        ),
        _buildOverviewAddButton(),
      ],
    );
  }

  Widget _buildExpiredAlert() {
    final expiredCount = _overview?.expiredCount ?? 0;
    if (expiredCount <= 0) return const SizedBox.shrink();

    final countLabel = expiredCount >= 100 ? '99+' : '$expiredCount';
    // 设计稿 v1.1 指定的过期强调深红色，对比度 5.8:1，主题暂无对应 token
    const deepRed = Color(0xFFC0392B);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        label: '您有${expiredCount >= 100 ? "99+" : "$expiredCount"}个物品已过期，点击查看',
        button: true,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => widget.onNavigateToInventory?.call('expired'),
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.currentColors.ih_negative.withValues(alpha: 0.12),
            highlightColor: AppTheme.currentColors.ih_negative.withValues(alpha: 0.06),
            child: Ink(
              decoration: BoxDecoration(
                color: AppTheme.currentColors.ih_negative.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.currentColors.ih_negative.withValues(alpha: 0.30),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 22,
                      color: deepRed,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: '您有 '),
                            TextSpan(
                              text: countLabel,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: deepRed,
                              ),
                            ),
                            const TextSpan(text: ' 个物品已过期，请及时处理'),
                          ],
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.currentColors.ih_text,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: deepRed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewAddButton() {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const AddItemModal(),
        );
        if (result == true && mounted) _loadData();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.currentColors.ih_surface_warm,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(Icons.add_rounded,
              color: AppTheme.currentColors.ih_text, size: 24),
        ),
      ),
    );
  }

  Widget _buildManageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.assignment_rounded,
                  color: AppTheme.currentColors.ih_text, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("管理您的厨房",
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.currentColors.ih_text)),
                  Text("追踪物品和使用情况",
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.currentColors.ih_text_secondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const AddItemModal(),
                );
                if (result == true && mounted) _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.currentColors.ih_accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text("添加物品",
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecipeCards() {
    if (_suggestions.isEmpty) {
      return [
        _buildRecipeCardStatic("暂无推荐", "请先添加库存物品"),
      ];
    }
    return _suggestions.map((s) {
      final subtitle = s.missingItemsCount == 0
          ? '食材齐全'
          : '还需要 ${s.missingItemsCount} 种食材';
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildRecipeCardStatic(s.title, subtitle),
      );
    }).toList();
  }

  Widget _buildRecipeCardStatic(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.currentColors.ih_surface_warm,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.restaurant_menu_rounded,
                    color: AppTheme.currentColors.ih_text, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.currentColors.ih_text)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.currentColors.ih_text_secondary)),
                ],
              ),
            ],
          ),
          Text("查看菜谱",
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_accent)),
        ],
      ),
    );
  }

  Widget _buildTopItemsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("常用物品",
            style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text)),
        GestureDetector(
          onTap: () => widget.onSwitchTab?.call(1),
          child: Text("查看全部",
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_accent)),
        ),
      ],
    );
  }

  Widget _buildTopItemsList() {
    if (_topItems.isEmpty) {
      return Text("暂无数据",
          style: GoogleFonts.inter(
              fontSize: 13, color: AppTheme.currentColors.ih_text_muted));
    }
    return Column(
      children: _topItems.map((item) {
        return _buildTopItemTile(item);
      }).toList(),
    );
  }

  Widget _buildTopItemTile(TopUsedItem topItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _onTopItemTapped(topItem),
          borderRadius: BorderRadius.circular(12),
          splashColor:
              AppTheme.currentColors.ih_accent.withValues(alpha: 0.08),
          highlightColor: AppTheme.currentColors.ih_surface_warm,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(topItem.name,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.currentColors.ih_text)),
                Text('${topItem.usageCount} 次使用',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.currentColors.ih_text_secondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ——— 常用物品交互方法 ———

  /// 点击常用物品：搜索匹配物品后弹出操作面板
  Future<void> _onTopItemTapped(TopUsedItem topItem) async {
    PaginatedData<PantryItem> paged;
    try {
      paged = await _pantryService.getItems(keyword: topItem.name, pageSize: 50);
    } on UnauthorizedException {
      if (!mounted) return;
      await AuthNotifier.instance.clearAuth();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
      return;
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    } on NetworkException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;

    final match = paged.items.cast<PantryItem?>().firstWhere(
          (item) => item?.name == topItem.name,
          orElse: () => null,
        );

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该物品已不在库存中')),
      );
      return;
    }

    await _showActionSheet(match);
  }

  /// 弹出食材操作面板，处理 edit/use/delete 信号
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

  /// 弹出编辑弹窗，成功后刷新首页数据
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

  /// 弹出使用食材对话框，成功后刷新首页数据
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

  /// 弹出删除确认对话框，确认后删除并刷新首页数据
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
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('删除成功')));
      await _loadData();
    } on UnauthorizedException {
      if (!mounted) return;
      await AuthNotifier.instance.clearAuth();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
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
}

// ——— 概览卡片（独立 StatefulWidget，各自维护高亮状态）———

class _OverviewCard extends StatefulWidget {
  const _OverviewCard({
    required this.label,
    required this.count,
    required this.cardColor,
    required this.rippleColor,
    required this.status,
    required this.onTap,
  });

  final String label;
  final String count;
  final Color cardColor;
  final Color rippleColor;
  // 物品状态标识（'fresh' / 'expiring' / 'expired'），用于语义标注与后续筛选扩展，
  // 当前由调用方通过 onTap 回调传入筛选参数，此字段作为语义锚点保留。
  final String status;
  final VoidCallback onTap;

  @override
  State<_OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<_OverviewCard> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.label}食材，共 ${widget.count} 件，点击查看',
      button: true,
      child: AnimatedScale(
        scale: _isHighlighted ? 0.95 : 1.0,
        duration: _isHighlighted
            ? const Duration(milliseconds: 100)
            : const Duration(milliseconds: 150),
        curve: _isHighlighted ? Curves.easeInOut : Curves.easeOut,
        child: Material(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(16),
          elevation: _isHighlighted ? 0.5 : 1.5,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: widget.rippleColor.withValues(alpha: 0.15),
            highlightColor: widget.rippleColor.withValues(alpha: 0.08),
            onHighlightChanged: (highlighted) {
              setState(() => _isHighlighted = highlighted);
            },
            onTap: widget.onTap,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.count,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.currentColors.ih_text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.currentColors.ih_text_secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
