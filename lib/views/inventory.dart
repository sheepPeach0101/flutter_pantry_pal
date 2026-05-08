import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/models/api_response.dart';
import 'package:PantryPal/models/pantry_item.dart';
import 'package:PantryPal/models/recipe.dart';
import 'package:PantryPal/services/pantry_service.dart';
import 'package:PantryPal/services/recipe_service.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _pantryService = PantryService();
  final _recipeService = RecipeService();

  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;

  List<PantryItem> _items = [];
  int _total = 0;
  List<RecipeSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _pantryService.getItems(
          page: 1,
          pageSize: 50,
          status: _selectedStatus,
        ),
        _recipeService.getSuggestions(limit: 2),
      ]);

      final paginated = results[0] as PaginatedData<PantryItem>;
      if (mounted) {
        setState(() {
          _items = paginated.items;
          _total = paginated.total;
          _suggestions = results[1] as List<RecipeSuggestion>;
          _isLoading = false;
        });
      }
    } on UnauthorizedException {
      if (mounted) {
        await AuthNotifier.instance.clearAuth();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, '/welcome', (route) => false);
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteItem(PantryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.name}"吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _pantryService.deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('删除成功')));
        _loadData();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on NetworkException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _onFilterChanged(String? status) {
    setState(() => _selectedStatus = status);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _loadData, child: const Text('重试')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: _buildContent(),
                  ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFilterRow(),
          const SizedBox(height: 16),
          _buildSectionTitle("库存状态 ($_total)"),
          const SizedBox(height: 12),
          _buildStockStatusList(),
          const SizedBox(height: 32),
          _buildSectionTitle("推荐菜谱"),
          const SizedBox(height: 12),
          ..._suggestions.map((s) {
            final subtitle = s.missingItemsCount == 0
                ? '基于现有食材推荐'
                : '还需要 ${s.missingItemsCount} 种食材';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecipeCard(s.title, subtitle),
            );
          }),
          if (_suggestions.isEmpty)
            _buildRecipeCard("暂无推荐", "请先添加库存物品"),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("厨房物品",
            style: GoogleFonts.ibmPlexSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.currentColors.ih_text)),
        Icon(Icons.menu_rounded,
            color: AppTheme.currentColors.ih_text_muted, size: 24),
      ],
    );
  }

  Widget _buildFilterRow() {
    final filters = [
      {'label': '全部', 'value': null},
      {'label': '新鲜', 'value': 'fresh'},
      {'label': '即将过期', 'value': 'expiring'},
      {'label': '已过期', 'value': 'expired'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStatus == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onFilterChanged(f['value']),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.currentColors.ih_accent
                      : AppTheme.currentColors.ih_surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  f['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.currentColors.ih_text_secondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.currentColors.ih_text_muted));
  }

  Widget _buildStockStatusList() {
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text("暂无物品",
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.currentColors.ih_text_muted)),
        ),
      );
    }

    return Column(
      children: _items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStockItem(item),
        );
      }).toList(),
    );
  }

  Widget _buildStockItem(PantryItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await _deleteItem(item);
        return false; // _loadData handles refresh
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.currentColors.ih_surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.currentColors.ih_text)),
                  Text(
                    "${item.quantity} ${item.unit} • ${item.statusLabel}",
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.currentColors.ih_text_secondary),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(item.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'fresh':
        color = Colors.green;
        break;
      case 'expiring':
        color = Colors.orange;
        break;
      case 'expired':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.currentColors.ih_text_secondary)),
        ],
      ),
    );
  }
}
