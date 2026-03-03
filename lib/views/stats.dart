import 'package:PantryPal/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFilter(),
              const SizedBox(height: 24),
              _buildMonthlyCard(),
              const SizedBox(height: 24),
              _buildChartCard(),
              const SizedBox(height: 24),
              _buildTopUsedCard(),
              const SizedBox(height: 100), // Bottom padding for footer
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "厨房统计",
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        Icon(
          Icons.description_outlined,
          color: AppTheme.currentColors.ih_text_muted,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildFilter() {
    return Text(
      "最近 30 天 ▼",
      style: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        color: AppTheme.currentColors.ih_text_secondary,
      ),
    );
  }

  Widget _buildMonthlyCard() {
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
          Text(
            "月度概览",
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              color: AppTheme.currentColors.ih_text_secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "75%",
            style: GoogleFonts.ibmPlexSans(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(0.75),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${(progress * 100).toInt()}%",
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.currentColors.ih_text_muted,
          ),
        ),
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
                    width: constraints.maxWidth * progress,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "上月使用的物品",
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.currentColors.ih_text_secondary,
            ),
          ),
          const SizedBox(height: 24),
          // Chart placeholder
          Container(
            height: 140,
            width: double.infinity,
            color: AppTheme.currentColors.ih_bg.withOpacity(0.5),
            child: const Center(
              child: Text("图表占位符"),
            ),
          ),
          const SizedBox(height: 12),
          _buildDayLabels(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "8 件物品",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.currentColors.ih_text_muted,
                ),
              ),
              Text(
                "15 个菜谱",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.currentColors.ih_text_muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    final days = ["一", "二", "三", "四", "五", "六", "日"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isHighlighted = day == "F";
        return Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            color: isHighlighted
                ? AppTheme.currentColors.ih_accent
                : AppTheme.currentColors.ih_text_muted,
          ),
        );
      }).toList(),
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
          Text(
            "前三位常用物品",
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTopUsedItem(Icons.restaurant_rounded, "苹果"),
              _buildTopUsedItem(Icons.grain_rounded, "米饭"),
              _buildTopUsedItem(Icons.spa_rounded, "胡萝卜"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsedItem(IconData icon, String name) {
    return Column(
      children: [
        Icon(
          icon,
          size: 40,
          color: AppTheme.currentColors.ih_text_secondary,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
      ],
    );
  }
}
