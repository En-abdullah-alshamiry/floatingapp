import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import 'product_listing_screen.dart';

const List<List<Color>> _kBgGradients = [
  [Color(0xFF3A2C1A), Color(0xFF16120C)],
  [Color(0xFF1C2B3A), Color(0xFF0E1218)],
  [Color(0xFF3A1F24), Color(0xFF16100F)],
  [Color(0xFF1C3A2A), Color(0xFF0E1812)],
  [Color(0xFF2A1C3A), Color(0xFF120E18)],
  [Color(0xFF3A341C), Color(0xFF16130C)],
];

/// التصنيفات الأساسية للتطبيق
/// التصنيفات الأساسية للتطبيق متوافقة مع Category Enum
const List<Map<String, String>> categories = [
  {
    'id': 'women',
    'nameEn': 'Women',
    'nameAr': 'ملابس نسائية',
    'icon': 'checkroom',
    'image': 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?q=80&w=500',
  },
  {
    'id': 'men',
    'nameEn': 'Men',
    'nameAr': 'ملابس رجالية',
    'icon': 'checkroom',
    'image': 'https://images.unsplash.com/photo-1488161628813-04466f872be2?q=80&w=500',
  },
  {
    'id': 'kids',
    'nameEn': 'Kids',
    'nameAr': 'ملابس أطفال',
    'icon': 'child_care',
    'image': 'https://images.unsplash.com/photo-1519702777585-fe688633b297?q=80&w=500',
  },
  {
    'id': 'shoes',
    'nameEn': 'Shoes',
    'nameAr': 'أحذية',
    'icon': 'footprints',
    'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500',
  },
  {
    'id': 'bags',
    'nameEn': 'Bags',
    'nameAr': 'حقائب',
    'icon': 'bag',
    'image': 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=500',
  },
  {
    'id': 'accessories',
    'nameEn': 'Accessories',
    'nameAr': 'إكسسوارات',
    'icon': 'watch',
    'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500',
  },
];

bool _isRtl(BuildContext context) {
  try {
    return Provider.of<LocaleProvider>(context).isRTL;
  } catch (_) {
    return AppLocalizations.of(context).isArabic;
  }
}

IconData _categoryIcon(String iconName) {
  switch (iconName) {
    case 'checkroom':
      return Icons.checkroom_rounded;

    case 'straighten':
      return Icons.straighten_rounded;

    case 'dry_cleaning':
      return Icons.dry_cleaning_rounded;

    case 'footprints':
      return Icons.directions_walk_rounded;

    case 'bag':
      return Icons.shopping_bag_rounded;

    case 'child_care':
      return Icons.child_care_rounded;

    case 'watch':
      return Icons.watch_rounded;

    default:
      return Icons.category_outlined;
  }
}

String _categoryName(
    Map<String, String> category,
    AppLocalizations l10n,
    ) {
  final id = category['id'] ?? '';

  final translated = l10n.tr(id);

  if (translated != id) {
    return translated;
  }

  return l10n.isArabic
      ? (category['nameAr'] ?? '')
      : (category['nameEn'] ?? '');
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// عدد المنتجات لكل تصنيف
  final Map<String, int> _categoryCounts = {};

  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _loadCategoryCounts();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryCounts() async {
    try {
      final products = await ApiService.instance.getProducts();

      final counts = <String, int>{};

      for (final category in categories) {
        final id = category['id'] ?? '';

        counts[id] = products
            .where(
              (product) =>
          product.category.name.toLowerCase() == id.toLowerCase(),
        )
            .length;
      }

      if (!mounted) return;

      setState(() {
        _categoryCounts
          ..clear()
          ..addAll(counts);

        _isLoadingCounts = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingCounts = false;

        for (final category in categories) {
          _categoryCounts[category['id'] ?? ''] = 0;
        }
      });
    }
  }

  Animation<double> _stagger(int index) {
    final begin = (index * 0.07).clamp(0.0, 0.5);
    final end = (0.45 + index * 0.07).clamp(0.5, 1.0);

    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        begin,
        end,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _openCategory(
      BuildContext context,
      Map<String, String> category,
      String name,
      ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return ProductListingScreen(
            category: category['id'],
            categoryName: name,
          );
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(
          milliseconds: 280,
        ),
      ),
    );
  }

  int _gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRTL = _isRtl(context);
    final columns = _gridColumns(context);

    return Directionality(
      textDirection:
      isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.tr('categories_title'),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24,
            ),
            physics: const BouncingScrollPhysics(),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              final name = _categoryName(
                category,
                l10n,
              );

              final categoryId =
                  category['id'] ?? '';

              final count =
                  _categoryCounts[categoryId] ?? 0;

              final gradientColors =
              _kBgGradients[
              index % _kBgGradients.length];

              return FadeTransition(
                opacity: _stagger(index),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(
                    _stagger(index),
                  ),
                  child: _CategoryCard(
                    name: name,
                    icon: _categoryIcon(
                      category['icon'] ?? '',
                    ),
                    count: count,
                    isLoading: _isLoadingCounts,
                    gradientColors: gradientColors,
                    imageUrl: category['image'],
                    onTap: () => _openCategory(
                      context,
                      category,
                      name,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final int count;
  final bool isLoading;
  final List<Color> gradientColors;
  final String? imageUrl;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.count,
    required this.isLoading,
    required this.gradientColors,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    final headingStyle = isArabic
        ? GoogleFonts.notoSansArabic(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.4,
    )
        : GoogleFonts.playfairDisplay(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.3,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.07,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.28,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null &&
                    imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _gradientBackground(),
                    errorWidget: (
                        context,
                        url,
                        error,
                        ) {
                      return _gradientBackground();
                    },
                  )
                else
                  _gradientBackground(),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(
                          alpha: 0.20,
                        ),
                        Colors.black.withValues(
                          alpha: 0.80,
                        ),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                          AppColors.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color:
                              AppColors.gold.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: headingStyle,
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          if (isLoading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          else
                            Text(
                              '$count',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),

                          const SizedBox(width: 4),

                          Flexible(
                            child: Text(
                              isLoading
                                  ? l10n.tr(
                                'loading',
                              )
                                  : count == 1
                                  ? l10n.tr(
                                'item',
                              )
                                  : l10n.tr(
                                'items',
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Icon(
                            isArabic
                                ? Icons
                                .arrow_back_ios_new_rounded
                                : Icons
                                .arrow_forward_ios_rounded,
                            size: 15,
                            color: AppColors.gold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradientBackground() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}