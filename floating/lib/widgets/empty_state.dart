import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const EmptyState({
    super.key,
    this.icon = Icons.storefront_outlined,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    final IconData arrow = actionIcon ??
        (Directionality.of(context) == TextDirection.rtl
            ? Icons.arrow_back_rounded
            : Icons.arrow_forward_rounded);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF2A2A2A),
                          Color(0xFF1A1A1A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          scheme.surfaceContainerHighest,
                          scheme.surfaceContainerLow,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 44,
                color: isDark ? AppColors.goldLight : AppColors.goldDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: (isArabic
                      ? GoogleFonts.notoSansArabic()
                      : GoogleFonts.playfairDisplay())
                  .copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: scheme.onSurface,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: (isArabic
                        ? GoogleFonts.notoSansArabic()
                        : GoogleFonts.inter())
                    .copyWith(
                  fontSize: 14,
                  height: 1.7,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(arrow, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}