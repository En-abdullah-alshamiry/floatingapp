import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            loc.tr('about_us'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            _buildLogoSection(colorScheme),
            const SizedBox(height: 24),
            _buildAppInfo(colorScheme, loc),
            const SizedBox(height: 32),
            _buildDescription(colorScheme, loc),
            const SizedBox(height: 32),
            _buildLinksSection(context, colorScheme, loc),
            const SizedBox(height: 32),
            _buildSocialSection(colorScheme),
            const SizedBox(height: 24),
            _buildCopyright(colorScheme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gold,
              AppColors.gold.withValues(alpha: 0.7),
              AppColors.gold.withValues(alpha: 0.9),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'F',
            style: GoogleFonts.playfairDisplay(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo(ColorScheme colorScheme, AppLocalizations loc) {
    return Column(
      children: [
        Text(
          loc.tr('app_name'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'v4.0.0',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ColorScheme colorScheme, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        loc.isArabic
            ? 'بينا فلو هو تطبيق أزياء راقي يقدم لك أحدث صيحات الموضة العالمية بجودة عالية وأسعار منافسة. اكتشف مجموعتنا الحصرية واستمتع بتجربة تسوق فريدة.'
            : 'BinaFlow is a premium fashion app bringing you the latest global trends with high quality and competitive prices. Discover our exclusive collection and enjoy a unique shopping experience.',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.7,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context, ColorScheme colorScheme, AppLocalizations loc) {
    final links = [
      {
        'icon': Icons.privacy_tip_outlined,
        'title': loc.tr('privacy_policy'),
        'color': Colors.blue,
      },
      {
        'icon': Icons.description_outlined,
        'title': loc.tr('terms_conditions'),
        'color': Colors.teal,
      },
      {
        'icon': Icons.help_outline,
        'title': loc.tr('help_center'),
        'color': Colors.orange,
      },
    ];

    return Column(
      children: links.map((link) {
        final linkColor = link['color'] as Color;
        final icon = link['icon'] as IconData;
        final title = link['title'] as String;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: linkColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: linkColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSocialSection(ColorScheme colorScheme) {
    final socialIcons = [
      {'icon': Icons.camera_alt_outlined, 'label': 'Instagram', 'color': Colors.pink},
      {'icon': Icons.facebook_rounded, 'label': 'Facebook', 'color': Colors.blue},
      {'icon': Icons.alternate_email, 'label': 'Twitter', 'color': Colors.lightBlue},
      {'icon': Icons.play_circle_outline, 'label': 'YouTube', 'color': Colors.red},
    ];

    return Column(
      children: [
        Text(
          'تابعنا',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: socialIcons.map((social) {
            final sColor = social['color'] as Color;
            final sIcon = social['icon'] as IconData;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(sIcon, color: sColor, size: 26),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCopyright(ColorScheme colorScheme) {
    return Column(
      children: [
        Divider(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          thickness: 1,
        ),
        const SizedBox(height: 16),
        Text(
          '© 2026 BinaFlow. All rights reserved.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Made with ❤ in Saudi Arabia',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
