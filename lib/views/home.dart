import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/views/navigation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              _buildSectionTitle("您的厨房概览"),
              const SizedBox(height: 12),
              _buildOverviewRow(),
              const SizedBox(height: 32),
              _buildManageCard(context),
              const SizedBox(height: 32),
              _buildSectionTitle("Suggested recipes"),
              const SizedBox(height: 12),
              _buildRecipeCard(),
              const SizedBox(height: 32),
              _buildSectionTitle("使用统计"),
              const SizedBox(height: 12),
              _buildUsageStats(),
              const SizedBox(height: 32),
              _buildTopItemsHeader(),
              const SizedBox(height: 12),
              _buildTopItemsList(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to",
              style: GoogleFonts.ibmPlexSans(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text,
              ),
            ),
            Text(
              "库存总量: 120",
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildOverviewItem(AppTheme.currentColors.ih_surface),
        _buildOverviewItem(AppTheme.currentColors.ih_surface),
        _buildOverviewItem(AppTheme.currentColors.ih_surface),
        _buildOverviewAddButton(),
      ],
    );
  }

  Widget _buildOverviewItem(Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildOverviewAddButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface_warm,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.add_rounded,
          color: AppTheme.currentColors.ih_text,
          size: 24,
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
              Icon(
                Icons.assignment_rounded,
                color: AppTheme.currentColors.ih_text,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "管理您的厨房",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.currentColors.ih_text,
                    ),
                  ),
                  Text(
                    "追踪物品和使用情况",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.currentColors.ih_text_secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const AddItemModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.currentColors.ih_accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: Text(
                "添加物品",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard() {
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
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppTheme.currentColors.ih_text,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "春天面条",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.currentColors.ih_text,
                    ),
                  ),
                  Text(
                    "根据库存推荐",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.currentColors.ih_text_secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "查看菜谱",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentColors.ih_accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatBubble("已使用物品", "50", "80% 已用"),
            const SizedBox(width: 12),
            _buildStatBubble("损耗", "12", "增长 5%"),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatBubble("库存价值", "\$450", "总价值"),
            const SizedBox(width: 12),
            _buildStatBubble("平均有效期", "14天", "改善 2天"),
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
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.currentColors.ih_text_muted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.currentColors.ih_accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopItemsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "常用物品",
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        Text(
          "查看全部",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text_muted,
          ),
        ),
      ],
    );
  }

  Widget _buildTopItemsList() {
    return Column(
      children: [
        _buildTopItemTile("苹果", "50 次使用"),
        _buildTopItemTile("牛奶", "30 次使用"),
        _buildTopItemTile("鸡蛋", "25 次使用"),
        _buildTopItemTile("面包", "20 次使用"),
      ],
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
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
          Text(
            uses,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.currentColors.ih_text_secondary,
            ),
          ),
        ],
      ),
    );
  }
}
