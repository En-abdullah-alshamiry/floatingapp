import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onViewAll;
  final EdgeInsets padding;
  final CrossAxisAlignment alignment;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onViewAll,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 12),
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final isRTL = context.watch<LocaleProvider>().isRTL;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: alignment,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (isArabic
                      ? GoogleFonts.notoSansArabic()
                      : GoogleFonts.playfairDisplay())
                  .copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 1.3,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (onViewAll != null) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: isRTL
                    ? AppColors.gold
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.goldLight
                        : AppColors.goldDark),
              ),
              icon: Icon(
                isRTL
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 14,
              ),
              label: Text(actionLabel ?? l10n.tr('view_all')),
            ),
          ],
        ],
      ),
    );
  }
}