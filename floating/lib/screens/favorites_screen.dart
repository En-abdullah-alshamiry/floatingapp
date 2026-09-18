import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/locale_provider.dart';
import '../models/product.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';

String _price(double amount, AppLocalizations l10n) {
  return '${amount.toStringAsFixed(2)} ${l10n.tr('currency')}';
}

IconData _categoryIcon(Category category) {
  switch (category) {
    case Category.men:
      return Icons.man_outlined;

    case Category.women:
      return Icons.woman_outlined;

    case Category.kids:
      return Icons.child_care_outlined;

    case Category.shoes:
      return Icons.snowshoeing;

    case Category.bags:
      return Icons.shopping_bag_outlined;

    case Category.accessories:
      return Icons.watch_outlined;
  }
}

String _colorToHex(Color color) {
  final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${value.substring(2).toUpperCase()}';
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  void _continueShopping(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
          (route) => false,
    );
  }

  int _gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    final isRTL = localeProvider.isRTL;
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    // نستخدم Product الجديد المخزن داخل FavoritesProvider
    final wishlist = favoritesProvider.favorites;

    return Directionality(
      textDirection:
      isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${l10n.tr('wishlist_title')} (${favoritesProvider.count})',
          ),
        ),
        body: SafeArea(
          child: wishlist.isEmpty
              ? _buildEmpty(
            context,
            isRTL,
            l10n,
            cs,
          )
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridColumns(context),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final product = wishlist[index];

              return Dismissible(
                key: ValueKey<String>(
                  'fav-${product.id}',
                ),
                direction: DismissDirection.horizontal,
                onDismissed: (_) {
                  favoritesProvider.removeFavorite(
                    product.id,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.tr(
                          'remove_from_wishlist',
                        ),
                      ),
                    ),
                  );
                },
                background: Container(
                  alignment: isRTL
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightError,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                child: _FavoriteCard(
                  product: product,
                  isRTL: isRTL,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.productDetails,
                      arguments: product,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.darkGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.6),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 40,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.tr('wishlist_empty'),
              style: isRTL
                  ? GoogleFonts.notoSansArabic(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              )
                  : GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tr('wishlist_empty_desc'),
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () =>
                  _continueShopping(context),
              icon: const Icon(
                Icons.shopping_bag_outlined,
              ),
              label: Text(
                l10n.tr('continue_shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.product,
    required this.isRTL,
    required this.onTap,
  });

  final Product product;
  final bool isRTL;
  final VoidCallback onTap;

  String get _name {
    return isRTL
        ? product.nameAr
        : product.nameEn;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final favorites =
    Provider.of<FavoritesProvider>(context);

    final cart =
    Provider.of<CartProvider>(context);

    // اللون الأساسي من ألوان المنتج
    final Color base = product.colors.isNotEmpty
        ? product.colors.first
        : cs.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.5),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة المنتج
                  if (product.images.isNotEmpty)
                    Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return _imageFallback(
                          context,
                          base,
                        );
                      },
                    )
                  else
                    _imageFallback(
                      context,
                      base,
                    ),

                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: isRTL ? null : 8,
                      right: isRTL ? 8 : null,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                          AppColors.saleGradient,
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${product.discountPercent.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 8,
                    right: isRTL ? null : 8,
                    left: isRTL ? 8 : null,
                    child: Material(
                      color: cs.surface
                          .withValues(alpha: 0.95),
                      shape:
                      const CircleBorder(),
                      elevation: 2,
                      shadowColor: cs.shadow,
                      child: InkWell(
                        customBorder:
                        const CircleBorder(),
                        onTap: () {
                          favorites
                              .toggleFavorite(
                            product,
                          );
                        },
                        child: const Padding(
                          padding:
                          EdgeInsets.all(8),
                          child: Icon(
                            Icons.favorite,
                            color:
                            AppColors.lightError,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _price(
                                product.discountPrice ??
                                    product.price,
                                l10n,
                              ),
                              style:
                              const TextStyle(
                                color:
                                AppColors.gold,
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),

                            if (product.hasDiscount)
                              Text(
                                _price(
                                  product.price,
                                  l10n,
                                ),
                                style:
                                TextStyle(
                                  color: cs
                                      .onSurfaceVariant,
                                  fontSize: 11,
                                  decoration:
                                  TextDecoration
                                      .lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 36,
                    child: Material(
                      color: AppColors.gold
                          .withValues(alpha: 0.15),
                      borderRadius:
                      BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius:
                        BorderRadius.circular(12),
                        onTap: () {
                          final selectedColor =
                          product.colors.isEmpty
                              ? null
                              : _colorToHex(
                            product
                                .colors
                                .first,
                          );

                          final selectedSize =
                          product.sizes.isEmpty
                              ? null
                              : product
                              .sizes
                              .first;

                          cart.addItem(
                            product,
                            color: selectedColor,
                            size: selectedSize,
                          );

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.tr(
                                  'added_to_cart',
                                ),
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons
                                    .add_shopping_cart,
                                size: 16,
                                color: AppColors
                                    .goldDark,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                l10n.tr(
                                  'add_to_cart',
                                ),
                                style:
                                const TextStyle(
                                  color:
                                  AppColors.black,
                                  fontWeight:
                                  FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(
      BuildContext context,
      Color base,
      ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            base.withValues(alpha: 0.30),
            base.withValues(alpha: 0.10),
            cs.surfaceContainerLowest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        _categoryIcon(product.category),
        size: 48,
        color: base.withValues(alpha: 0.7),
      ),
    );
  }
}