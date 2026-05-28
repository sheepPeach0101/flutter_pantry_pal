import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/services/pantry_service.dart';
import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// UseItemDialog — 使用食材居中弹窗
///
/// 显示食材当前库存，提供步进按钮与数字输入框双向联动，
/// 校验后调用 PantryService.useItem() 扣减库存。
/// 成功后通过 Navigator.pop(context, true) 通知父页面刷新。
class UseItemDialog extends StatefulWidget {
  const UseItemDialog({
    super.key,
    required this.item,
  });

  final PantryItem item;

  @override
  State<UseItemDialog> createState() => _UseItemDialogState();
}

class _UseItemDialogState extends State<UseItemDialog> {
  late final TextEditingController _quantityController;
  int _quantity = 1;
  bool _isSubmitting = false;
  String? _errorMessage;

  final _pantryService = PantryService();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _quantityController.addListener(_onQuantityTextChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onQuantityTextChanged);
    _quantityController.dispose();
    super.dispose();
  }

  void _onQuantityTextChanged() {
    final parsed = int.tryParse(_quantityController.text);
    if (parsed != null && parsed != _quantity) {
      setState(() => _quantity = parsed);
    }
  }

  void _decrement() {
    if (_quantity <= 1) return;
    final next = _quantity - 1;
    setState(() => _quantity = next);
    _quantityController.text = next.toString();
  }

  void _increment() {
    if (_quantity >= widget.item.quantity) return;
    final next = _quantity + 1;
    setState(() => _quantity = next);
    _quantityController.text = next.toString();
  }

  String? _validate() {
    final text = _quantityController.text.trim();
    if (text.isEmpty) return '请输入使用数量';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0) return '使用数量必须为正整数';
    if (parsed > widget.item.quantity) return '使用数量不能超过当前库存';
    return null;
  }

  Future<void> _handleSubmit() async {
    final error = _validate();
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final usedQty = int.parse(_quantityController.text.trim());

    try {
      await _pantryService.useItem(widget.item.id, quantity: usedQty);
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context, true);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '已使用 $usedQty ${widget.item.unit} ${widget.item.name}',
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isSubmitting = false;
        });
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isSubmitting = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = '操作失败，请稍后重试';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.currentColors;

    return Semantics(
      label: '使用食材弹窗',
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.ih_surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleRow(colors),
              const SizedBox(height: 8),
              _buildItemInfoCard(colors),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                _buildErrorBanner(_errorMessage!),
                const SizedBox(height: 12),
              ],
              _buildQuantityInputArea(colors),
              const SizedBox(height: 24),
              _buildActionRow(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(dynamic colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.remove_circle_outline,
          size: 20,
          color: colors.ih_accent,
        ),
        const SizedBox(width: 8),
        Text(
          '使用食材',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.ih_text,
          ),
        ),
      ],
    );
  }

  Widget _buildItemInfoCard(dynamic colors) {
    final item = widget.item;
    return Semantics(
      label: '${item.name}，剩余 ${item.quantity} ${item.unit}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.ih_surface_warm,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.ih_text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '剩余 ${item.quantity} ${item.unit}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colors.ih_text_secondary,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildQuantityInputArea(dynamic colors) {
    final item = widget.item;
    final isDecrementDisabled = _isSubmitting || _quantity <= 1;
    final isIncrementDisabled = _isSubmitting || _quantity >= item.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '使用数量',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.ih_text,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildStepperButton(
              icon: Icons.remove_rounded,
              semanticsLabel: '减少数量',
              isDisabled: isDecrementDisabled,
              onTap: _decrement,
              colors: colors,
            ),
            const SizedBox(width: 12),
            _buildQuantityTextField(colors),
            const SizedBox(width: 12),
            _buildStepperButton(
              icon: Icons.add_rounded,
              semanticsLabel: '增加数量',
              isDisabled: isIncrementDisabled,
              onTap: _increment,
              colors: colors,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '最多可使用 ${item.quantity} ${item.unit}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: colors.ih_text_muted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required String semanticsLabel,
    required bool isDisabled,
    required VoidCallback onTap,
    required dynamic colors,
  }) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      enabled: !isDisabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: colors.ih_accent_soft,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.ih_surface_warm,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDisabled ? colors.ih_text_muted : colors.ih_text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityTextField(dynamic colors) {
    return Semantics(
      label: '使用数量输入，当前 $_quantity ${widget.item.unit}',
      child: SizedBox(
        width: 80,
        child: TextField(
          controller: _quantityController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.ih_text,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.ih_border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.ih_border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colors.ih_accent,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: colors.ih_surface,
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(dynamic colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(
            '取消',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _isSubmitting
                  ? colors.ih_text_muted
                  : colors.ih_text_secondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: _isSubmitting ? '正在提交' : '确认使用',
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.ih_accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colors.ih_accent.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    '确认使用',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
