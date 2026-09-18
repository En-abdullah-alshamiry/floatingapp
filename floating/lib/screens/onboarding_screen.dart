import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });

  final IconData icon;
  final String titleKey;
  final String descriptionKey;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<_OnboardPage> _pages = [
    _OnboardPage(
      icon: Icons.checkroom_rounded,
      titleKey: 'onboarding_title_1',
      descriptionKey: 'onboarding_desc_1',
    ),
    _OnboardPage(
      icon: Icons.shopping_bag_rounded,
      titleKey: 'onboarding_title_2',
      descriptionKey: 'onboarding_desc_2',
    ),
    _OnboardPage(
      icon: Icons.star_rounded,
      titleKey: 'onboarding_title_3',
      descriptionKey: 'onboarding_desc_3',
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      final next = _currentPage + 1;
      setState(() => _currentPage = next);
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Directionality(
            textDirection: l10n.textDirection,
            child: Column(
              children: [
                Align(
                  alignment: l10n.endAlignment,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
                    child: TextButton.icon(
                      onPressed: _finish,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(l10n.tr('skip')),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _OnboardingPageView(
                      page: _pages[index],
                      isArabic: isArabic,
                    ),
                  ),
                ),
                _buildDots(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: _buildNextButton(l10n, isArabic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final active = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.gold : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton(AppLocalizations l10n, bool isArabic) {
    final isLast = _currentPage == _pages.length - 1;
    final label =
        isLast ? (isArabic ? 'ابدأ الآن' : 'Get Started') : l10n.tr('next');
    final IconData arrowIcon = isLast
        ? Icons.check_rounded
        : (isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: _onNext,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(arrowIcon, size: 20, color: AppColors.black),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page, required this.isArabic});

  final _OnboardPage page;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 36,
                  ),
                ],
              ),
              child: Icon(page.icon, size: 54, color: AppColors.black),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            l10n.tr(page.titleKey),
            textAlign: TextAlign.center,
            style: (isArabic
                    ? GoogleFonts.notoSansArabic()
                    : GoogleFonts.playfairDisplay())
                .copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tr(page.descriptionKey),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white70,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}