import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/models/stats.dart';
import 'package:PantryPal/models/recipe.dart';
import 'package:PantryPal/services/pantry_service.dart';
import 'package:PantryPal/services/stats_service.dart';
import 'package:PantryPal/services/recipe_service.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:PantryPal/views/navigation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pantryService = PantryService();
  final _statsService = StatsService();
  final _recipeService = RecipeService();

  bool _isLoading = true;
  String? _errorMessage;

  PantryOverview? _overview;
  MonthlyStats? _monthlyStats;
  List<TopUsedItem> _topItems = [];
  List<RecipeSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _pantryService.getOverview(),
        _statsService.getMonthlyStats(days: 30),
        _statsService.getTopUsed(limit: 4),
        _recipeService.getSuggestions(limit: 3),
      ]);

      if (mounted) {
        setState(() {
          _overview = results[0] as PantryOverview;
          _monthlyStats = results[1] as MonthlyStats;
          _topItems = results[2] as List<TopUsedItem>;
          _suggestions = results[3] as List<RecipeSuggestion>;
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSectionTitle("您的厨房概览"),
          const SizedBox(height: 12),
          _buildOverviewRow(),
          const SizedBox(height: 32),
          _buildManageCard(context),
          const SizedBox(height: 32),
          _buildSectionTitle("推荐菜谱"),
          const SizedBox(height: 12),
          ..._buildRecipeCards(),
          const SizedBox(height: 32),
          _buildSectionTitle("使用统计"),
          const SizedBox(height: 12),
          _buildUsageStats(),
          const SizedBox(height: 32),
          _buildTopItemsHeader(),
          const SizedBox(height: 12),
          _buildTopItemsList(),
          const SizedBox(height: 100),
        ],
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildOverviewItem("新鲜", '${ov?.freshCount ?? 0}',
            AppTheme.currentColors.ih_surface),
        _buildOverviewItem("即将过期", '${ov?.expiringCount ?? 0}',
            AppTheme.currentColors.ih_surface),
        _buildOverviewItem("已过期", '${ov?.expiredCount ?? 0}',
            AppTheme.currentColors.ih_surface),
        _buildOverviewAddButton(),
      ],
    );
  }

  Widget _buildOverviewItem(String label, String count, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.currentColors.ih_text_secondary,
            ),
          ),
        ],
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

  Widget _buildUsageStats() {
    final stats = _monthlyStats;
    final usagePercent =
        stats != null ? '${(stats.usageRate * 100).toInt()}%' : '0%';
    final wasteStr = stats != null ? '${stats.wasteCount}' : '0';
    final wasteGrowth = stats != null
        ? '增长 ${(stats.wasteGrowthRate * 100).toInt()}%'
        : '';
    final totalValue =
        stats != null ? '¥${stats.totalValue.toStringAsFixed(0)}' : '¥0';
    final shelfLife = stats != null
        ? '${stats.avgShelfLifeDays.toStringAsFixed(0)}天'
        : '0天';
    final shelfImprove = stats != null
        ? '改善 ${stats.shelfLifeImprovementDays.toStringAsFixed(0)}天'
        : '';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatBubble(
                "已使用物品", '${stats?.usedItemsCount ?? 0}', '$usagePercent 已用'),
            const SizedBox(width: 12),
            _buildStatBubble("损耗", wasteStr, wasteGrowth),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatBubble("库存价值", totalValue, "总价值"),
            const SizedBox(width: 12),
            _buildStatBubble("平均有效期", shelfLife, shelfImprove),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBubble(String label, String value, String sub) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppTheme.currentColors.ih_text_muted)),
          Text(value,
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.currentColors.ih_text)),
          Text(sub,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppTheme.currentColors.ih_accent)),
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
        Text("查看全部",
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text_muted)),
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
      children:
          _topItems.map((item) {
            return _buildTopItemTile(item.name, '${item.usageCount} 次使用');
          }).toList(),
    );
  }

  Widget _buildTopItemTile(String name, String uses) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.currentColors.ih_text)),
          Text(uses,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.currentColors.ih_text_secondary)),
        ],
      ),
    );
  }
}
