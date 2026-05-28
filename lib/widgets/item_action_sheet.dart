import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ItemActionSheet — 食材卡片底部操作面板
///
/// 弹出三个操作入口：编辑、使用、删除，所有入口均已激活。
/// 所有操作均通过 Navigator.pop(context, action) 返回信号给父页面处理：
/// - 编辑：返回 'edit'，由父页面弹出 EditItemModal
/// - 使用：返回 'use'，由父页面弹出 UseItemDialog 扣减库存并记录消耗
/// - 删除：返回 'delete'，由父页面执行确认删除流程
///
/// 使用示例（InventoryPage 中）：
/// ```dart
/// final action = await showModalBottomSheet<String>(
///   context: context,
///   backgroundColor: Colors.transparent,
///   builder: (_) => ItemActionSheet(item: item),
/// );
/// if (action == 'edit' && mounted) {
///   await _showEditModal(item);
/// } else if (action == 'use' && mounted) {
///   await _showUseDialog(item);
/// } else if (action == 'delete' && mounted) {
///   await _confirmAndDelete(item);
/// }
/// ```
class ItemActionSheet extends StatelessWidget {
  const ItemActionSheet({
    super.key,
    required this.item,
  });

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.currentColors.ih_surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 8),
            _buildItemHeader(),
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.currentColors.ih_border,
            ),
            _buildEditAction(context),
            _buildUseAction(context),
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.currentColors.ih_border,
            ),
            _buildDeleteAction(context),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.currentColors.ih_border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildItemHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.currentColors.ih_text,
            ),
          ),
          Text(
            '${item.quantity} ${item.unit}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.currentColors.ih_text_secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditAction(BuildContext context) {
    return _buildActionRow(
      context: context,
      semanticsLabel: '编辑 ${item.name}',
      onTap: () => Navigator.pop(context, 'edit'),
      icon: Icons.edit_outlined,
      iconColor: AppTheme.currentColors.ih_text,
      splashColor: AppTheme.currentColors.ih_accent.withValues(alpha: 0.08),
      highlightColor: AppTheme.currentColors.ih_surface_warm,
      label: '编辑',
      labelColor: AppTheme.currentColors.ih_text,
    );
  }

  Widget _buildUseAction(BuildContext context) {
    return Semantics(
      label: '使用 ${item.name}，记录消耗',
      button: true,
      child: InkWell(
        onTap: () => Navigator.pop(context, 'use'),
        splashColor: AppTheme.currentColors.ih_accent.withValues(alpha: 0.08),
        highlightColor: AppTheme.currentColors.ih_surface_warm,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 22,
                    color: AppTheme.currentColors.ih_accent,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使用',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.currentColors.ih_text,
                      ),
                    ),
                    Text(
                      '记录消耗',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.currentColors.ih_text_muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAction(BuildContext context) {
    return Semantics(
      label: '删除 ${item.name}，此操作不可恢复',
      button: true,
      hint: '此操作不可恢复',
      child: InkWell(
        onTap: () => Navigator.pop(context, 'delete'),
        splashColor: AppTheme.currentColors.ih_negative.withValues(alpha: 0.08),
        highlightColor: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 22,
                    color: AppTheme.currentColors.ih_negative,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '删除',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.currentColors.ih_negative,
                      ),
                    ),
                    Text(
                      '此操作不可恢复',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.currentColors.ih_text_muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required BuildContext context,
    required String semanticsLabel,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required Color splashColor,
    required Color highlightColor,
    required String label,
    required Color labelColor,
  }) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
