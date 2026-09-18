import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';
import '../models/product.dart';
import '../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;
  final double imageAspectRatio;
  final String? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 176,
    this.imageAspectRatio = 0.85,
    this.heroTag,
  });

  String _formatPrice(double value) {
    return value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  String? _colorToHex(Color color) {
    final value = color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0');

    return '#${value.substring(2).toUpperCase()}';
  }

  LinearGradient _imageGradient(BuildContext context) {
    final scheme = Theme
        .of(context)
        .colorScheme;
    final isDark =
        Theme
            .of(context)
            .brightness == Brightness.dark;

    Color base;

    if (product.colors.isNotEmpty) {
      base = product.colors.first;
    } else {
      base = isDark
          ? const Color(0xFF3B3B3B)
          : scheme.primaryContainer;
    }

    final hsl = HSLColor.fromColor(base);

    final light = hsl
        .withLightness(
      (hsl.lightness + 0.16).clamp(0.0, 1.0),
    )
        .toColor();

    final dark = hsl
        .withLightness(
      (hsl.lightness - 0.18).clamp(0.0, 1.0),
    )
        .toColor();

    return LinearGradient(
      colors: [light, base, dark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme
        .of(context)
        .colorScheme;

    final isDark =
        Theme
            .of(context)
            .brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    final favorites =
    context.watch<FavoritesProvider>();

    final bool isFavorite =
    favorites.isFavorite(product.id);

    final String tag =
        heroTag ?? 'product-${product.id}';

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: isDark ? 2 : 3,
        shadowColor: scheme.shadow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap ??
                  () =>
                  Navigator.of(context).pushNamed(
                    AppRoutes.productDetails,
                    arguments: product,
                  ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildImageSection(
                context,
                tag,
                isArabic,
                isFavorite,
                isDark,
              ),
              _buildInfoSection(
                context,
                scheme,
                l10n,
                isArabic,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context,
      String tag,
      bool isArabic,
      bool isFavorite,
      bool isDark,) {
    return Hero(
      tag: tag,
      child: AspectRatio(
        aspectRatio: imageAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (product.images.isNotEmpty)
              CachedNetworkImage(
                imageUrl: product.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      highlightColor: isDark ? Colors.grey[700]! : Colors
                          .grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                errorWidget: (context, url, error) => _imageFallback(context),
              )
            else
              _imageFallback(context),


            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      if (product.hasDiscount)
                        _Badge(
                          label:
                          '-${product.discountPercent.round()}%',
                          gradient:
                          AppColors.saleGradient,
                          textColor:
                          AppColors.white,
                        ),

                      if (product.isNew)
                        _Badge(
                          label:
                          isArabic ? 'جديد' : 'New',
                          gradient:
                          AppColors.goldGradient,
                          textColor:
                          AppColors.black,
                        ),

                      if (product.isBestSeller)
                        _Badge(
                          label: isArabic
                              ? 'الأكثر مبيعاً'
                              : 'Best Seller',
                          gradient:
                          AppColors.darkGradient,
                          textColor:
                          AppColors.white,
                        ),
                    ],
                  ),

                  Material(
                    color: AppColors.black
                        .withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder:
                      const CircleBorder(),
                      onTap: () =>
                          favoritesToggler(
                            context,
                            product,
                          ),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons
                              .favorite_border_rounded,
                          size: 18,
                          color: isFavorite
                              ? Colors.redAccent
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                const EdgeInsets.fromLTRB(
                  10,
                  18,
                  10,
                  10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.transparent,
                      AppColors.black
                          .withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.gold,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      product.rating
                          .toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        '(${product.reviewCount})',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white
                              .withValues(
                            alpha: 0.75,
                          ),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _imageGradient(context),
      ),
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 72,
          color: Colors.white.withValues(
            alpha: 0.22,
          ),
        ),
      ),
    );
  }

  void favoritesToggler(BuildContext context,
      Product product,) {
    context
        .read<FavoritesProvider>()
        .toggleFavorite(product);
  }

  Widget _buildInfoSection(BuildContext context,
      ColorScheme scheme,
      AppLocalizations l10n,
      bool isArabic,) {
    final isDark =
        Theme
            .of(context)
            .brightness ==
            Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            product.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (isArabic
                ? GoogleFonts.notoSansArabic()
                : GoogleFonts.inter())
                .copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.3,
              color: scheme.onSurface,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.baseline,
                      textBaseline:
                      TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            _formatPrice(
                              product.hasDiscount
                                  ? product.discountPrice!
                                  : product.price,
                            ),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: (isArabic
                                ? GoogleFonts
                                .notoSansArabic()
                                : GoogleFonts
                                .inter())
                                .copyWith(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w800,
                              color: isDark
                                  ? AppColors
                                  .goldLight
                                  : AppColors
                                  .goldDark,
                            ),
                          ),
                        ),

                        const SizedBox(width: 3),

                        Text(
                          l10n.tr('currency'),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                            scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    if (product.hasDiscount) ...[
                      const SizedBox(height: 2),

                      Text(
                        _formatPrice(
                          product.price,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                          scheme.onSurfaceVariant,
                          decoration:
                          TextDecoration
                              .lineThrough,
                          decorationColor:
                          scheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _MiniCartButton(
                onTap: () =>
                    addToCart(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addToCart(BuildContext context) {
    final cart =
    context.read<CartProvider>();

    final l10n =
    AppLocalizations.of(context);

    cart.addItem(
      product,
      color: product.colors.isNotEmpty
          ? _colorToHex(product.colors.first)
          : null,
      size: product.sizes.isNotEmpty
          ? product.sizes.first
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.tr('added_to_cart'),
          ),
          duration:
          const Duration(seconds: 2),
        ),
      );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.gradient,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 6),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius:
        BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black
                .withValues(alpha: 0.2),
            blurRadius: 6,
            offset:
            const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.inter().copyWith(
          fontSize: 10,
          fontWeight:
          FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

class _MiniCartButton
extends StatelessWidget {
  final VoidCallback onTap;

  const _MiniCartButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient:
          AppColors.goldGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold
                  .withValues(alpha: 0.4),
              blurRadius: 8,
              offset:
              const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_bag_outlined,
          size: 17,
          color: AppColors.black,
        ),
      ),
    );
  }
}