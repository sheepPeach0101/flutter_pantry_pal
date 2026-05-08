import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/models/user.dart';
import 'package:PantryPal/services/user_service.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await _userService.getProfile();
      AuthNotifier.instance.setUser(user);
      if (mounted) {
        setState(() {
          _user = user;
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('退出', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthNotifier.instance.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/welcome', (route) => false);
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '未知';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.currentColors.ih_text_secondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
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
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 24),
        Text(
          "个人中心",
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
          _user?.name ?? _user?.email ?? '未知用户',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.currentColors.ih_text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _user?.role != null ? '• ${_user!.role}' : '',
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
          _buildDetailRow("职位", _user?.role ?? '未设置'),
          const SizedBox(height: 12),
          _buildDetailRow("邮箱", _user?.email ?? '未知', isAccent: true),
          const SizedBox(height: 12),
          _buildDetailRow("手机", _user?.phone ?? '未填写'),
          const SizedBox(height: 12),
          _buildDetailRow("最后登录", _formatDateTime(_user?.lastLoginAt)),
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
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isAccent
                  ? AppTheme.currentColors.ih_accent
                  : AppTheme.currentColors.ih_text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(context, "编辑资料"),
        const SizedBox(height: 16),
        _buildActionButton(context, "偏好设置"),
        const SizedBox(height: 16),
        _buildActionButton(context, "退出登录", isLogout: true),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label,
      {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        if (isLogout) _handleLogout();
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
