import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, String> category;
  final int? productCount;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final IconData? fallbackIcon;

  const CategoryCard({
    super.key,
    required this.category,
    this.productCount,
    this.onTap,
    this.gradient = AppColors.goldGradient,
    this.fallbackIcon = Icons.category_rounded,
  });

  IconData get _icon {
    final key = category['icon'] ?? '';

    switch (key) {
      case 'checkroom':
        return Icons.checkroom_rounded;

      case 'straighten':
        return Icons.straighten_rounded;

      case 'dry_cleaning':
        return Icons.dry_cleaning_rounded;

      case 'footprints':
        return Icons.directions_walk;

      case 'watch':
        return Icons.watch_rounded;

      case 'man':
        return Icons.man_rounded;

      case 'woman':
        return Icons.woman_rounded;

      case 'child':
        return Icons.child_care_rounded;

      case 'shoe':
        return Icons.directions_walk_rounded;

      case 'bag':
        return Icons.shopping_bag_rounded;

      case 'accessory':
        return Icons.diamond_rounded;

      case 'diamond':
        return Icons.diamond_rounded;

      default:
        return fallbackIcon ?? Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    final name = isArabic
        ? (category['nameAr'] ??
        category['nameEn'] ??
        '')
        : (category['nameEn'] ??
        category['nameAr'] ??
        '');

    final int count = productCount ?? 0;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(
                  alpha: 0.18,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(
                      alpha: 0.22,
                    ),
                    border: Border.all(
                      color:
                      AppColors.white.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _icon,
                    size: 24,
                    color: AppColors.white,
                  ),
                ),

                const Spacer(),

                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (isArabic
                      ? GoogleFonts.notoSansArabic()
                      : GoogleFonts.playfairDisplay())
                      .copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.3,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.local_offer_outlined,
                      size: 13,
                      color: AppColors.white,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      isArabic
                          ? '$count منتج'
                          : '$count Products',
                      style: GoogleFonts.inter().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                        AppColors.white.withValues(
                          alpha: 0.85,
                        ),
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
}