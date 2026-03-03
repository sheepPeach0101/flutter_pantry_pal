import 'package:PantryPal/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.currentColors.ih_bg,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Splash Image Placeholder
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppTheme.currentColors.ih_surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.kitchen_rounded,
                      size: 140,
                      color: AppTheme.currentColors.ih_accent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "PantryPal",
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.currentColors.ih_text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "您的智能厨房管家",
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppTheme.currentColors.ih_text_secondary,
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.currentColors.ih_accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "已有账号？去登录",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.currentColors.ih_text_secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
