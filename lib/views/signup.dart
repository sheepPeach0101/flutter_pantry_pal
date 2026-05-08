import 'package:PantryPal/theme/index.dart';
import 'package:PantryPal/services/auth_service.dart';
import 'package:PantryPal/utils/auth_notifier.dart';
import 'package:PantryPal/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '请填写邮箱和密码');
      return;
    }

    if (password.length < 8) {
      setState(() => _errorMessage = '密码最少 8 位');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authData = await _authService.signup(email, password);
      await AuthNotifier.instance.login(authData);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } on NetworkException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = '注册失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 80,
                  color: AppTheme.currentColors.ih_text_muted,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "PantryPal",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.currentColors.ih_text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "加入我们，轻松管理您的厨房",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  color: AppTheme.currentColors.ih_text_secondary,
                ),
              ),
              const SizedBox(height: 48),
              // 错误提示
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 表单
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "邮箱 *",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.currentColors.ih_text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "user@email.com",
                      hintStyle: GoogleFonts.inter(
                        color: AppTheme.currentColors.ih_text_muted,
                        fontSize: 14,
                      ),
                      suffixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: AppTheme.currentColors.ih_text_muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "密码 *",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.currentColors.ih_text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "••••••••（至少 8 位）",
                      hintStyle: GoogleFonts.inter(
                        color: AppTheme.currentColors.ih_text_muted,
                        fontSize: 14,
                      ),
                      suffixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.currentColors.ih_text_muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.currentColors.ih_surface_warm,
                        foregroundColor: AppTheme.currentColors.ih_text,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("注册"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "已有账号？ ",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.currentColors.ih_text_secondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: Text(
                      "去登录",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.currentColors.ih_text,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
