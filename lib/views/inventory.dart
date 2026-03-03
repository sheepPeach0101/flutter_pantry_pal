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
              _buildSectionTitle("STOCK STATUS"),
              const SizedBox(height: 12),
              _buildStockStatusList(),
              const SizedBox(height: 32),
              _buildSectionTitle("RECIPE SUGGESTIONS"),
              const SizedBox(height: 12),
              _buildRecipeCard(
                  "Pasta Primavera", "Based on available ingredients"),
              const SizedBox(height: 12),
              _buildRecipeCard("Chicken Stir Fry", "Requires 2 more items"),
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
          "Pantry Items",
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
        _buildStockItem("Apples", "10 units", "Expiring soon"),
        const SizedBox(height: 12),
        _buildStockItem("Milk", "2 liters", "Fresh"),
        const SizedBox(height: 12),
        _buildStockItem("Eggs", "12 items", "Expiring in 5 days"),
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
