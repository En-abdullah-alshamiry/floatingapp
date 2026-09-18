import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Directionality(
          textDirection: l10n.textDirection,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Spacer(),
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: const _LogoMark(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Text(
                          'BinaFlow',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tr('app_tagline'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.goldLight,
                            letterSpacing: 0.4,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.gold,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 124,
          height: 124,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 48,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Text(
            'F',
            style: GoogleFonts.playfairDisplay(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'FASHION',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 6,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}