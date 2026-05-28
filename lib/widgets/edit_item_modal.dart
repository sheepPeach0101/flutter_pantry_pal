import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/services/pantry_service.dart';
import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// EditItemModal — 编辑库存物品的浮动卡片弹窗
///
/// 视觉风格与 AddItemModal 完全一致（margin 24, padding 24, radius 24）。
/// 接收 [item] 预填所有字段，调用 PantryService.updateItem() 提交更改。
/// 成功后通过 Navigator.pop(context, true) 通知父页面刷新。
class EditItemModal extends StatefulWidget {
  const EditItemModal({
    super.key,
    required this.item,
  });

  final PantryItem item;

  @override
  State<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends State<EditItemModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _notesController;

  final _pantryService = PantryService();

  DateTime? _selectedDate;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item.name);
    _quantityController =
        TextEditingController(text: item.quantity.toString());
    _unitController = TextEditingController(text: item.unit);
    _notesController = TextEditingController(text: item.notes ?? '');
    _selectedDate = item.expirationDate;
  }

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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
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
    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0) {
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
      final notesText = _notesController.text.trim();
      await _pantryService.updateItem(
        widget.item.id,
        name: name,
        quantity: qty,
        unit: unit,
        expirationDate: dateStr,
        notes: notesText.isNotEmpty ? notesText : null,
      );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context, true);
        messenger.showSnackBar(const SnackBar(content: Text('修改成功')));
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } on NetworkException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = '保存失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
            _buildTitleRow(),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 12),
            ],
            _buildDateField(),
            const SizedBox(height: 20),
            _buildFormContainer(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '编辑物品',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        Icon(
          Icons.edit_rounded,
          size: 16,
          color: AppTheme.currentColors.ih_text,
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '有效期',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppTheme.currentColors.ih_text_muted,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : '选择日期',
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

  Widget _buildFormContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface_warm,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 16,
                color: AppTheme.currentColors.ih_text,
              ),
              const SizedBox(width: 8),
              Text(
                '修改物品信息',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('物品名称', _nameController, hintText: '例如：苹果', maxLength: 50),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  '数量',
                  _quantityController,
                  hintText: '10',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildTextField('单位', _unitController, hintText: '个'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            '备注（选填）',
            _notesController,
            hintText: '例如：红富士',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          enabled: !_isSubmitting,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.currentColors.ih_text,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.currentColors.ih_text_muted,
            ),
            counterText: maxLength != null ? '' : null,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: AppTheme.currentColors.ih_border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: AppTheme.currentColors.ih_border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.currentColors.ih_accent,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.currentColors.ih_surface,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: _isSubmitting ? '正在保存' : null,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.currentColors.ih_accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                AppTheme.currentColors.ih_accent.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  '保存',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
