import 'package:PantryPal/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

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
              const SizedBox(height: 32),
              _buildSectionTitle("库存状态"),
              const SizedBox(height: 12),
              _buildStockStatusList(),
              const SizedBox(height: 32),
              _buildSectionTitle("推荐菜谱"),
              const SizedBox(height: 12),
              _buildRecipeCard("春天面条", "基于现有食材推荐"),
              const SizedBox(height: 12),
              _buildRecipeCard("小炒鸡", "还需要 2 种食材"),
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
          "厨房物品",
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        Icon(
          Icons.menu_rounded,
          color: AppTheme.currentColors.ih_text_muted,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.currentColors.ih_text_muted,
      ),
    );
  }

  Widget _buildStockStatusList() {
    return Column(
      children: [
        _buildStockItem("苹果", "10 个", "即将过期"),
        const SizedBox(height: 12),
        _buildStockItem("牛奶", "2 升", "新鲜"),
        const SizedBox(height: 12),
        _buildStockItem("鸡蛋", "12 个", "5 天后过期"),
      ],
    );
  }

  Widget _buildStockItem(String name, String qty, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text,
                ),
              ),
              Text(
                "$qty • $status",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.currentColors.ih_text_secondary,
                ),
              ),
            ],
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.currentColors.ih_border,
                width: 2,
              ),
            ),
          ),
        ],
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.currentColors.ih_text_secondary,
            ),
          ),
        ],
      ),
    );
  }
}
