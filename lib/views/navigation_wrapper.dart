import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/services/pantry_service.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:PantryPal/views/home.dart';
import 'package:PantryPal/views/inventory.dart';
import 'package:PantryPal/views/stats.dart';
import 'package:PantryPal/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
    const Center(child: Text("Add Placeholder")),
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

  Future<void> _showAddModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AddItemModal(),
    );
    if (result == true && mounted) {
      // Force rebuild child pages so they reload data
      setState(() {});
    }
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

class AddItemModal extends StatefulWidget {
  const AddItemModal({super.key});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: '个');
  final _notesController = TextEditingController();
  final _pantryService = PantryService();

  DateTime? _selectedDate;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final qtyText = _quantityController.text.trim();
    final unit = _unitController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = '请输入物品名称');
      return;
    }
    if (qtyText.isEmpty || int.tryParse(qtyText) == null) {
      setState(() => _errorMessage = '请输入有效数量');
      return;
    }
    if (unit.isEmpty) {
      setState(() => _errorMessage = '请输入单位');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _errorMessage = '请选择有效期');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      await _pantryService.createItem(
        name: name,
        quantity: int.parse(qtyText),
        unit: unit,
        expirationDate: dateStr,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context, true); // true = item added
        messenger.showSnackBar(const SnackBar(content: Text('添加成功')));
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } on NetworkException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = '添加失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
              Text("新增物品录入",
                  style: GoogleFonts.ibmPlexSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.currentColors.ih_text)),
              Icon(Icons.edit_rounded,
                  color: AppTheme.currentColors.ih_text, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          // 错误提示
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_errorMessage!,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.red.shade700)),
            ),
            const SizedBox(height: 12),
          ],
          // 有效期选择
          _buildDateField(),
          const SizedBox(height: 20),
          // 表单
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.currentColors.ih_surface_warm,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_rounded,
                        color: AppTheme.currentColors.ih_text, size: 16),
                    const SizedBox(width: 8),
                    Text("输入物品信息",
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.currentColors.ih_text)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField("物品名称", _nameController,
                    hintText: '例如：苹果'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: _buildTextField("数量", _quantityController,
                            keyboardType: TextInputType.number,
                            hintText: '10')),
                    const SizedBox(width: 12),
                    Expanded(
                        flex: 1,
                        child: _buildTextField("单位", _unitController,
                            hintText: '个')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField("备注（选填）", _notesController,
                    hintText: '例如：红富士'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.currentColors.ih_accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text("添加",
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
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
        Text("有效期",
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: AppTheme.currentColors.ih_text_muted, size: 16),
              const SizedBox(width: 8),
              Text(
                _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : "选择日期",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _selectedDate != null
                      ? AppTheme.currentColors.ih_text
                      : AppTheme.currentColors.ih_text_muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.currentColors.ih_text_secondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: AppTheme.currentColors.ih_text_muted),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.currentColors.ih_border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.currentColors.ih_border),
            ),
            filled: true,
            fillColor: AppTheme.currentColors.ih_surface,
          ),
        ),
      ],
    );
  }
}
