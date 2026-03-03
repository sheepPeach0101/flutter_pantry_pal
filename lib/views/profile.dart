import 'package:PantryPal/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _buildHeader(context),
              const SizedBox(height: 48),
              _buildAvatar(),
              const SizedBox(height: 16),
              _buildUserInfo(),
              const SizedBox(height: 32),
              _buildDetails(),
              const SizedBox(height: 32),
              _buildActions(context),
              const SizedBox(height: 100), // Bottom padding for footer
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.currentColors.ih_text,
            size: 24,
          ),
        ),
        Text(
          "Profile Settings",
          style: GoogleFonts.ibmPlexSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        Icon(
          Icons.search_rounded,
          color: AppTheme.currentColors.ih_text,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 64,
          color: AppTheme.currentColors.ih_text_muted,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          "Alex Johnson",
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "• Managing",
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.currentColors.ih_text_secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
      ),
      child: Column(
        children: [
          _buildDetailRow("Role", "Pantry Manager"),
          const SizedBox(height: 12),
          _buildDetailRow("Email", "alex@pantrypal.com", isAccent: true),
          const SizedBox(height: 12),
          _buildDetailRow("Mobile", "N/A"),
          const SizedBox(height: 12),
          _buildDetailRow("Last login", "2026-02-04 15:45"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAccent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.currentColors.ih_text_muted,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isAccent
                ? AppTheme.currentColors.ih_accent
                : AppTheme.currentColors.ih_text,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(context, "Edit"),
        const SizedBox(height: 16),
        _buildActionButton(context, "Preferences"),
        const SizedBox(height: 16),
        _buildActionButton(context, "Logout", isLogout: true),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label,
      {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/welcome', (route) => false);
        }
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.currentColors.ih_surface_warm,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
        ),
      ),
    );
  }
}
