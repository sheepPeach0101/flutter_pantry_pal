import 'package:PantryPal/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
              // Signup Icon Placeholder
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
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
                  fontWeight: FontWeight.normal,
                  color: AppTheme.currentColors.ih_text_secondary,
                ),
              ),
              const SizedBox(height: 48),
              // Form Fields
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
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "••••••••",
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
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.currentColors.ih_surface_warm,
                        foregroundColor: AppTheme.currentColors.ih_text,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text("注册"),
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
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
