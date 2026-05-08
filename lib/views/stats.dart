import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/models/stats.dart';
import 'package:PantryPal/services/stats_service.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _statsService = StatsService();

  bool _isLoading = true;
  String? _errorMessage;
  int _selectedDays = 30;

  MonthlyStats? _monthlyStats;
  List<TopUsedItem> _topItems = [];

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
        _statsService.getMonthlyStats(days: _selectedDays),
        _statsService.getTopUsed(limit: 3),
      ]);

      if (mounted) {
        setState(() {
          _monthlyStats = results[0] as MonthlyStats;
          _topItems = results[1] as List<TopUsedItem>;
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

  void _changeDays(int days) {
    setState(() => _selectedDays = days);
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
          const SizedBox(height: 24),
          _buildFilter(),
          const SizedBox(height: 24),
          _buildMonthlyCard(),
          const SizedBox(height: 24),
          _buildChartCard(),
          const SizedBox(height: 24),
          _buildTopUsedCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("厨房统计",
            style: GoogleFonts.ibmPlexSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text)),
        Icon(Icons.description_outlined,
            color: AppTheme.currentColors.ih_text_muted, size: 20),
      ],
    );
  }

  Widget _buildFilter() {
    return PopupMenuButton<int>(
      onSelected: _changeDays,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 7, child: Text('最近 7 天')),
        const PopupMenuItem(value: 30, child: Text('最近 30 天')),
        const PopupMenuItem(value: 90, child: Text('最近 90 天')),
      ],
      child: Text(
        "最近 $_selectedDays 天 ▼",
        style: GoogleFonts.ibmPlexSans(
            fontSize: 13, color: AppTheme.currentColors.ih_text_secondary),
      ),
    );
  }

  Widget _buildMonthlyCard() {
    final stats = _monthlyStats;
    final usagePercent = stats != null ? (stats.usageRate * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
        border: Border.all(color: AppTheme.currentColors.ih_border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("月度概览",
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  color: AppTheme.currentColors.ih_text_secondary)),
          const SizedBox(height: 8),
          Text("$usagePercent%",
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text)),
          const SizedBox(height: 16),
          _buildProgressBar(stats?.usageRate ?? 0),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("${(progress * 100).toInt()}%",
            style: GoogleFonts.inter(
                fontSize: 12, color: AppTheme.currentColors.ih_text_muted)),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.currentColors.ih_bg,
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: AppTheme.currentColors.ih_accent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    final stats = _monthlyStats;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("使用概况",
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.currentColors.ih_text_secondary)),
          const SizedBox(height: 24),
          // 简单的文字统计代替图表
          _buildStatRow("已使用物品", '${stats?.usedItemsCount ?? 0}'),
          const SizedBox(height: 8),
          _buildStatRow("损耗物品", '${stats?.wasteCount ?? 0}'),
          const SizedBox(height: 8),
          _buildStatRow("库存价值",
              '¥${stats?.totalValue.toStringAsFixed(0) ?? '0'}'),
          const SizedBox(height: 8),
          _buildStatRow("平均保质期",
              '${stats?.avgShelfLifeDays.toStringAsFixed(0) ?? '0'} 天'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppTheme.currentColors.ih_text_muted)),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text)),
      ],
    );
  }

  Widget _buildTopUsedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("前三位常用物品",
              style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text)),
          const SizedBox(height: 16),
          if (_topItems.isEmpty)
            Center(
                child: Text("暂无数据",
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.currentColors.ih_text_muted)))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _topItems.map((item) {
                return _buildTopUsedItem(
                    Icons.restaurant_rounded, item.name, item.usageCount);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopUsedItem(IconData icon, String name, int count) {
    return Column(
      children: [
        Icon(icon, size: 40, color: AppTheme.currentColors.ih_text_secondary),
        const SizedBox(height: 8),
        Text(name,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppTheme.currentColors.ih_text)),
        Text('$count次',
            style: GoogleFonts.inter(
                fontSize: 10, color: AppTheme.currentColors.ih_text_muted)),
      ],
    );
  }
}
