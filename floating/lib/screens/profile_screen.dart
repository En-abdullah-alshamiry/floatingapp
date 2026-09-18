import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/favorites_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD USER PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final user = await _authService.getUserProfile();

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  void _logout(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.tr('logout')),
          content: Text(l10n.tr('are_you_sure')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.tr('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await _authService.logout();

                if (!mounted) return;

                if (!context.mounted) return;

                // العودة لشاشة تسجيل الدخول عبر الـ Navigator الرئيسي لإخفاء البار السفلي
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                      (route) => false,
                );
              },
              child: Text(l10n.tr('confirm')),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EDIT PROFILE
  // ============================================================

  Future<void> _openEditProfile() async {
    if (!mounted) return;

    final result = await Navigator.of(context).pushNamed(
      AppRoutes.editProfile,
    );

    if (!mounted) return;

    if (result == true) {
      await _loadProfile();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favorites = Provider.of<FavoritesProvider>(context);

    final isRTL = localeProvider.isRTL;
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tr('profile_title')),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.gold,
            ),
          )
              : Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isWide
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildProfileHeader(
                          context,
                          cs,
                          _user,
                          isRTL: isRTL,
                          l10n: l10n,
                        ),
                        _SectionCard(
                          title: l10n.tr('my_account'),
                          children: [
                            _MenuTile(
                              icon: Icons.person_outline,
                              label: l10n.tr('edit_profile'),
                              isRTL: isRTL,
                              onTap: _openEditProfile,
                            ),
                            _MenuTile(
                              icon: Icons.receipt_long_outlined,
                              label: l10n.tr('my_orders'),
                              isRTL: isRTL,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.orders),
                            ),
                            _MenuTile(
                              icon: Icons.location_on_outlined,
                              label: l10n.tr('my_addresses'),
                              isRTL: isRTL,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.addresses),
                            ),
                            _MenuTile(
                              icon: Icons.favorite_border,
                              label: l10n.tr('my_wishlist'),
                              isRTL: isRTL,
                              trailing: Text(
                                '(${favorites.count})',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.wishlist),
                            ),
                            _MenuTile(
                              icon: Icons.credit_card_outlined,
                              label: l10n.tr('payment_methods'),
                              isRTL: isRTL,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.paymentMethods),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _SectionCard(
                          title: l10n.tr('settings'),
                          children: [
                            _LanguageTile(
                              currentCode:
                              localeProvider.locale.languageCode,
                              onChanged: (code) {
                                localeProvider.setLocale(
                                  Locale(code == 'ar' ? 'ar' : 'en'),
                                );
                              },
                            ),
                            _ThemeSection(
                              themeMode: themeProvider.themeMode,
                              onChanged: (mode) {
                                themeProvider.setThemeMode(mode);
                              },
                            ),
                            SwitchListTile(
                              secondary: Icon(
                                Icons.notifications_none,
                                color: cs.primary,
                              ),
                              title: Text(l10n.tr('notifications')),
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _SectionCard(
                          title: l10n.tr('support'),
                          children: [
                            _MenuTile(
                              icon: Icons.support_agent,
                              label: l10n.tr('help_center'),
                              isRTL: isRTL,
                              onTap: () {},
                            ),
                            _MenuTile(
                              icon: Icons.email_outlined,
                              label: l10n.tr('contact_us'),
                              isRTL: isRTL,
                              onTap: () {},
                            ),
                            _MenuTile(
                              icon: Icons.privacy_tip_outlined,
                              label: l10n.tr('privacy_policy'),
                              isRTL: isRTL,
                              onTap: () {},
                            ),
                            _MenuTile(
                              icon: Icons.description_outlined,
                              label: l10n.tr('terms_conditions'),
                              isRTL: isRTL,
                              onTap: () {},
                            ),
                          ],
                        ),
                        _SectionCard(
                          title: l10n.tr('about'),
                          children: [
                            _MenuTile(
                              icon: Icons.info_outline,
                              label: l10n.tr('about_us'),
                              isRTL: isRTL,
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.about),
                            ),
                            ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.straighten,
                                  size: 20,
                                  color: cs.primary,
                                ),
                              ),
                              title: Text(l10n.tr('version')),
                              trailing: Text(
                                '1.0.0',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: () => _logout(context, l10n),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.lightError,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.logout),
                              label: Text(l10n.tr('logout')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildProfileHeader(
                    context,
                    cs,
                    _user,
                    isRTL: isRTL,
                    l10n: l10n,
                  ),

                  _SectionCard(
                    title: l10n.tr('my_account'),
                    children: [
                      _MenuTile(
                        icon: Icons.person_outline,
                        label: l10n.tr('edit_profile'),
                        isRTL: isRTL,
                        onTap: _openEditProfile,
                      ),

                      _MenuTile(
                        icon: Icons.receipt_long_outlined,
                        label: l10n.tr('my_orders'),
                        isRTL: isRTL,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.orders),
                      ),

                      _MenuTile(
                        icon: Icons.location_on_outlined,
                        label: l10n.tr('my_addresses'),
                        isRTL: isRTL,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.addresses),
                      ),

                      _MenuTile(
                        icon: Icons.favorite_border,
                        label: l10n.tr('my_wishlist'),
                        isRTL: isRTL,
                        trailing: Text(
                          '(${favorites.count})',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.wishlist),
                      ),

                      _MenuTile(
                        icon: Icons.credit_card_outlined,
                        label: l10n.tr('payment_methods'),
                        isRTL: isRTL,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.paymentMethods),
                      ),
                    ],
                  ),

                  _SectionCard(
                    title: l10n.tr('settings'),
                    children: [
                      _LanguageTile(
                        currentCode:
                        localeProvider.locale.languageCode,
                        onChanged: (code) {
                          localeProvider.setLocale(
                            Locale(code == 'ar' ? 'ar' : 'en'),
                          );
                        },
                      ),

                      _ThemeSection(
                        themeMode: themeProvider.themeMode,
                        onChanged: (mode) {
                          themeProvider.setThemeMode(mode);
                        },
                      ),

                      SwitchListTile(
                        secondary: Icon(
                          Icons.notifications_none,
                          color: cs.primary,
                        ),
                        title: Text(l10n.tr('notifications')),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  _SectionCard(
                    title: l10n.tr('support'),
                    children: [
                      _MenuTile(
                        icon: Icons.support_agent,
                        label: l10n.tr('help_center'),
                        isRTL: isRTL,
                        onTap: () {},
                      ),
                      _MenuTile(
                        icon: Icons.email_outlined,
                        label: l10n.tr('contact_us'),
                        isRTL: isRTL,
                        onTap: () {},
                      ),
                      _MenuTile(
                        icon: Icons.privacy_tip_outlined,
                        label: l10n.tr('privacy_policy'),
                        isRTL: isRTL,
                        onTap: () {},
                      ),
                      _MenuTile(
                        icon: Icons.description_outlined,
                        label: l10n.tr('terms_conditions'),
                        isRTL: isRTL,
                        onTap: () {},
                      ),
                    ],
                  ),

                  _SectionCard(
                    title: l10n.tr('about'),
                    children: [
                      _MenuTile(
                        icon: Icons.info_outline,
                        label: l10n.tr('about_us'),
                        isRTL: isRTL,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.about),
                      ),

                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.straighten,
                            size: 20,
                            color: cs.primary,
                          ),
                        ),
                        title: Text(l10n.tr('version')),
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      24,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => _logout(context, l10n),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.lightError,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.tr('logout')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(
      BuildContext context,
      ColorScheme cs,
      UserModel? user, {
        required bool isRTL,
        required AppLocalizations l10n,
      }) {
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'User';

    final email = user?.email ?? '';

    final photoUrl = user?.photoURL;

    final initials = _initials(name);

    // التحقق من أن المسار ليس فارغاً وأن الملف موجود فعلاً
    final hasLocalImage = photoUrl != null &&
        photoUrl.isNotEmpty &&
        File(photoUrl).existsSync();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // PROFILE IMAGE
          // ======================================================

          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: !hasLocalImage
                  ? AppColors.goldGradient
                  : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
              image: hasLocalImage
                  ? DecorationImage(
                image: FileImage(File(photoUrl)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: !hasLocalImage
                ? Center(
              child: Text(
                initials,
                style: isRTL
                    ? GoogleFonts.notoSansArabic(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                )
                    : GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            )
                : null,
          ),

          const SizedBox(height: 16),

          // ======================================================
          // NAME
          // ======================================================

          Text(
            name,
            style: isRTL
                ? GoogleFonts.notoSansArabic(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )
                : GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // ======================================================
          // EMAIL
          // ======================================================

          Text(
            email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          // ======================================================
          // PHONE
          // ======================================================

          if (user?.phoneNumber != null &&
              user!.phoneNumber!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              user.phoneNumber!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 12),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 15,
                color: AppColors.gold,
              ),
              const SizedBox(width: 6),
              Text(
                user?.isEmailVerified == true
                    ? 'البريد الإلكتروني موثق'
                    : 'البريد الإلكتروني غير موثق',
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 56),
                child: Divider(height: 1),
              ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ================================================================
// MENU TILE
// ================================================================

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.isRTL,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isRTL;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: cs.primary,
        ),
      ),
      title: Text(label),
      trailing: trailing ??
          Transform.flip(
            flipX: isRTL,
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ),
      onTap: onTap,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }
}

// ================================================================
// LANGUAGE TILE
// ================================================================

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.currentCode,
    required this.onChanged,
  });

  final String currentCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.language,
                  size: 20,
                  color: AppColors.goldDark,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.tr('language'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LanguageChip(
                  label: l10n.tr('arabic'),
                  selected: currentCode == 'ar',
                  onTap: () => onChanged('ar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LanguageChip(
                  label: l10n.tr('english'),
                  selected: currentCode == 'en',
                  onTap: () => onChanged('en'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// LANGUAGE CHIP
// ================================================================

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.gold.withValues(alpha: 0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.7)
                  : Theme.of(context)
                  .colorScheme
                  .outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: selected
                    ? AppColors.goldDark
                    : Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: selected
                      ? AppColors.goldDark
                      : Theme.of(context)
                      .colorScheme
                      .onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// THEME SECTION
// ================================================================

class _ThemeSection extends StatelessWidget {
  const _ThemeSection({
    required this.themeMode,
    required this.onChanged,
  });

  final ThemeModeOption themeMode;
  final ValueChanged<ThemeModeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: AppColors.goldDark,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.tr('theme'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _RadioOption(
            icon: Icons.light_mode_outlined,
            label: l10n.tr('theme_light'),
            selected: themeMode == ThemeModeOption.light,
            onTap: () => onChanged(ThemeModeOption.light),
          ),
          _RadioOption(
            icon: Icons.dark_mode_outlined,
            label: l10n.tr('theme_dark'),
            selected: themeMode == ThemeModeOption.dark,
            onTap: () => onChanged(ThemeModeOption.dark),
          ),
          _RadioOption(
            icon: Icons.brightness_auto_outlined,
            label: l10n.tr('theme_system'),
            selected: themeMode == ThemeModeOption.system,
            onTap: () => onChanged(ThemeModeOption.system),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// RADIO OPTION
// ================================================================

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? AppColors.goldDark
                  : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected
                  ? AppColors.gold
                  : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}