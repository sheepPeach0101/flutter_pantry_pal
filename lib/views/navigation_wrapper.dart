import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/views/home.dart';
import 'package:PantryPal/views/inventory.dart';
import 'package:PantryPal/views/stats.dart';
import 'package:PantryPal/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const InventoryPage(),
    const Center(child: Text("Add Placeholder")), // This is handled by a modal
    const StatsPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      _showAddModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AddItemModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.currentColors.ih_surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.currentColors.ih_border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, _currentIndex == 0),
            _buildNavItem(1, Icons.list_rounded, _currentIndex == 1),
            _buildAddButton(),
            _buildNavItem(3, Icons.info_outline_rounded, _currentIndex == 3),
            _buildNavItem(4, Icons.settings_rounded, _currentIndex == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, bool isActive) {
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Icon(
        icon,
        size: 24,
        color: isActive
            ? AppTheme.currentColors.ih_accent
            : AppTheme.currentColors.ih_text_muted,
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.currentColors.ih_surface_warm,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.add_rounded,
          size: 32,
          color: AppTheme.currentColors.ih_text_muted,
        ),
      ),
    );
  }
}

class AddItemModal extends StatelessWidget {
  const AddItemModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "新增物品录入",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text,
                ),
              ),
              Icon(
                Icons.edit_rounded,
                color: AppTheme.currentColors.ih_text,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDateField(),
          const SizedBox(height: 20),
          _buildForm(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.currentColors.ih_accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                "添加",
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "有效期",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.currentColors.ih_text_muted,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              "选择日期",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.currentColors.ih_text_muted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface_warm,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_rounded,
                color: AppTheme.currentColors.ih_text,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                "输入物品信息",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInput("物品名称"),
          const SizedBox(height: 12),
          _buildInput("数量"),
          const SizedBox(height: 12),
          _buildInput("备注"),
        ],
      ),
    );
  }

  Widget _buildInput(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.currentColors.ih_text_secondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.currentColors.ih_surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.currentColors.ih_border),
          ),
        ),
      ],
    );
  }
}
