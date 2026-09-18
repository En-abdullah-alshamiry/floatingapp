import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/api_service.dart';
import '../widgets/banner_carousel.dart';

import 'cart_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // مفاتيح التنقل لكل تبويب للحفاظ على القائمة السفلية ثابتة في كل الشاشات
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    // الحصول على النفيجيتور الخاص بالتبويب الذي تم النقر عليه
    final navigator = _navigatorKeys[index].currentState;

    if (navigator != null) {
      // تصفير المسار بالكامل والعودة للشاشة الرئيسية للتبويب دائمًا
      // هذا يضمن أنه عند النقر على "الأقسام" نعود للجذر حتى لو كنا في صفحة فرعية
      // ويضمن أيضاً إعادة تحميل البيانات والأنيميشن
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    }

    // الانتقال للتبويب في PageView إذا لم يكن هو التبويب الحالي
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => rootPage,
            settings: const RouteSettings(name: '/'),
          );
        }
        return AppRoutes.generateRoute(settings);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final navigator = _navigatorKeys[_currentIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else if (_currentIndex != 0) {
          // العودة للتبويب الأول عند ضغط زر الرجوع إذا كنا في تبويب آخر
          _onTabSelected(0);
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            _buildTabNavigator(0, const _HomeTab()),
            _buildTabNavigator(1, const CategoriesScreen()),
            _buildTabNavigator(2, const FavoritesScreen()),
            _buildTabNavigator(3, const CartScreen()),
            _buildTabNavigator(4, const ProfileScreen()),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          backgroundColor: colors.surface,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: colors.onSurfaceVariant,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 16,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l10n.tr('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined),
              activeIcon: const Icon(Icons.grid_view_rounded),
              label: l10n.tr('nav_categories'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_outline),
              activeIcon: const Icon(Icons.favorite_rounded),
              label: l10n.tr('nav_wishlist'),
            ),
            BottomNavigationBarItem(
              icon: const _CartBadgeIcon(active: false),
              activeIcon: const _CartBadgeIcon(active: true),
              label: l10n.tr('nav_cart'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outlined),
              activeIcon: const Icon(Icons.person_rounded),
              label: l10n.tr('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CART BADGE
// ============================================================

class _CartBadgeIcon extends StatelessWidget {
  const _CartBadgeIcon({
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final count = cart.itemCount;

        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: Icon(
            active
                ? Icons.shopping_bag_rounded
                : Icons.shopping_bag_outlined,
          ),
        );
      },
    );
  }
}

// ============================================================
// HOME TAB
// ============================================================

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ApiService _apiService = ApiService.instance;

  List<Product> _products = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _apiService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  double _screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  bool _isSmallScreen(BuildContext context) {
    return _screenWidth(context) < 360;
  }

  bool _isTablet(BuildContext context) {
    return _screenWidth(context) >= 600;
  }

  double _hPad(BuildContext context) {
    if (_isTablet(context)) return 32;
    if (_isSmallScreen(context)) return 16;
    return 24;
  }

  int _gridColumns(BuildContext context) {
    final width = _screenWidth(context);

    if (width >= 900) return 4;
    if (width >= 600) return 3;

    return 2;
  }

  double _productRowHeight(BuildContext context) {
    if (_isTablet(context)) return 300;
    if (_isSmallScreen(context)) return 240;

    return 264;
  }

  double _productCardWidth(BuildContext context) {
    if (_isTablet(context)) return 200;
    if (_isSmallScreen(context)) return 148;

    return 168;
  }

  // ============================================================
  // PRODUCT LISTS
  // ============================================================

  List<Product> get _newArrivals {
    final products = _products
        .where((product) => product.isNew)
        .toList();

    // إذا لم يرسل الـ API منتجات مصنفة كجديدة،
    // نستخدم أول 10 منتجات بدلاً من ظهور القسم فارغاً.
    if (products.isEmpty) {
      return _products.take(10).toList();
    }

    return products.take(10).toList();
  }

  List<Product> get _bestSellers {
    final products = List<Product>.from(_products);

    products.sort(
          (a, b) => b.rating.compareTo(a.rating),
    );

    return products.take(10).toList();
  }

  List<Product> get _recommendedProducts {
    return _products.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surfaceContainerLowest,
            colors.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              _buildTopBar(context),
              _buildGreeting(context),
              _buildSearchBar(context),
              const SizedBox(height: 24),
              BannerCarousel(
                height: _isTablet(context) ? 260 : 215,
              ),

              _sectionHeader(
                context,
                l10n.tr('categories_title'),
                    () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.categories,
                  );
                },
              ),

              _buildCategories(context),

              _sectionHeader(
                context,
                l10n.tr('new_arrivals'),
                    () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.categories,
                  );
                },
              ),

              _buildProductRow(
                context,
                _newArrivals,
              ),

              _sectionHeader(
                context,
                l10n.tr('best_sellers'),
                    () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.categories,
                  );
                },
              ),

              _buildProductRow(
                context,
                _bestSellers,
              ),

              _sectionHeader(
                context,
                l10n.tr('recommended'),
                    () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.categories,
                  );
                },
              ),

              _buildRecommendedGrid(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pad = _hPad(context);

    final fontSize =
    _isSmallScreen(context) ? 18.0 : 22.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        pad,
        16,
        pad - 8,
        8,
      ),
      child: Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment:
              AlignmentDirectional.centerStart,
              child: Text(
                'HAWANA',
                style: GoogleFonts.playfairDisplay(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.notifications,
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
            color: colors.onSurface,
            padding: const EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final isArabic = l10n.isArabic;

    final pad = _hPad(context);

    final nameFontSize =
    _isSmallScreen(context) ? 22.0 : 26.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        pad,
        8,
        pad,
        0,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            isArabic
                ? 'مرحباً بك في متجر هوانا'
                : 'Welcome to HAWANA',
            style: (isArabic
                ? GoogleFonts.notoSansArabic()
                : GoogleFonts.playfairDisplay())
                .copyWith(
              fontSize: nameFontSize,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isArabic
                ? 'اكتشفي أحدث صيحات الموضة لكِ'
                : 'Discover the latest styles for you',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final pad = _hPad(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        pad,
        20,
        pad,
        0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.search,
          );
        },
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius:
            BorderRadius.circular(28),
            border: Border.all(
              color:
              AppColors.gold.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.gold,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.tr('search_hint'),
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                    colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.tune_rounded,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader(
      BuildContext context,
      String title,
      VoidCallback onViewAll,
      ) {
    final colors =
        Theme.of(context).colorScheme;

    final l10n =
    AppLocalizations.of(context);

    final isArabic = l10n.isArabic;

    final pad = _hPad(context);

    final titleFontSize =
    _isSmallScreen(context)
        ? 17.0
        : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        pad,
        28,
        pad,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: (isArabic
                  ? GoogleFonts.notoSansArabic()
                  : GoogleFonts.playfairDisplay())
                  .copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onViewAll,
            borderRadius:
            BorderRadius.circular(12),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    l10n.tr('view_all'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    isArabic
                        ? Icons
                        .arrow_back_ios_rounded
                        : Icons
                        .arrow_forward_ios_rounded,
                    size: 14,
                    color:
                    AppColors.gold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories(
      BuildContext context,
      ) {
    final pad = _hPad(context);

    final chipWidth =
    _isTablet(context) ? 110.0 : 92.0;

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: pad,
        ),
        itemCount: Category.values.length,
        separatorBuilder:
            (context, index) =>
        const SizedBox(width: 12),
        itemBuilder:
            (context, index) {
          final category =
          Category.values[index];

          return _CategoryChip(
            name: category.arName,
            imageUrl: category.imageUrl,
            width: chipWidth,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.categoryDetails,
                arguments: {
                  'id': category.name,
                  'nameAr': category.arName,
                  'nameEn': category.enName,
                },
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT ROW
  // ============================================================

  Widget _buildProductRow(
      BuildContext context,
      List<Product> products,
      ) {
    if (_isLoading) {
      return SizedBox(
        height:
        _productRowHeight(context),
        child: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorMessage(
        context,
      );
    }

    if (products.isEmpty) {
      return _buildEmptyProducts(
        context,
      );
    }

    final pad = _hPad(context);

    return SizedBox(
      height:
      _productRowHeight(context),
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: pad,
        ),
        itemCount: products.length,
        separatorBuilder:
            (context, index) =>
        const SizedBox(width: 16),
        itemBuilder:
            (context, index) {
          return _ProductCard(
            product: products[index],
            width:
            _productCardWidth(context),
          );
        },
      ),
    );
  }

  // ============================================================
  // RECOMMENDED GRID
  // ============================================================

  Widget _buildRecommendedGrid(
      BuildContext context,
      ) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorMessage(
        context,
      );
    }

    if (_recommendedProducts.isEmpty) {
      return _buildEmptyProducts(
        context,
      );
    }

    final pad = _hPad(context);

    final columns =
    _gridColumns(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: pad,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
        const NeverScrollableScrollPhysics(),
        itemCount:
        _recommendedProducts.length,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        itemBuilder:
            (context, index) {
          return _ProductCard(
            product:
            _recommendedProducts[index],
            grid: true,
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 45,
          ),
          const SizedBox(height: 10),
          const Text(
            'تعذر تحميل المنتجات',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadProducts,
            child:
            const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts(
      BuildContext context,
      ) {
    return const Padding(
      padding:
      EdgeInsets.all(24),
      child: Center(
        child: Text(
          'لا توجد منتجات حالياً',
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY CHIP
// ============================================================

class _CategoryChip
    extends StatelessWidget {
  const _CategoryChip({
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.width = 92,
  });

  final String name;
  final String imageUrl;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient:
          LinearGradient(
            begin:
            Alignment.topLeft,
            end:
            Alignment.bottomRight,
            colors: [
              AppColors.gold.withValues(
                alpha: 0.16,
              ),
              colors
                  .surfaceContainerHigh
                  .withValues(
                alpha: 0.5,
              ),
            ],
          ),
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color:
            AppColors.gold.withValues(
              alpha: 0.28,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              clipBehavior: Clip.antiAlias,
              decoration:
              BoxDecoration(
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                shape:
                BoxShape.circle,
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.category_outlined, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: width - 16,
              child: Text(
                name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign:
                TextAlign.center,
                style:
                GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _ProductCard
    extends StatelessWidget {
  const _ProductCard({
    required this.product,
    this.width,
    this.grid = false,
  });

  final Product product;
  final double? width;
  final bool grid;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colors =
        Theme.of(context).colorScheme;

    final l10n =
    AppLocalizations.of(context);

    final isArabic =
        l10n.isArabic;

    return SizedBox(
      width: width,
      child: Container(
        clipBehavior:
        Clip.antiAlias,
        decoration:
        BoxDecoration(
          color:
          colors.surfaceContainer,
          borderRadius:
          BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color:
            colors.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.productDetails,
              arguments: product,
            );
          },
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .stretch,
            children: [
              Expanded(
                child: _ProductImage(
                  product: product,
                  isArabic:
                  isArabic,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  12,
                  10,
                  8,
                  12,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      product.displayName,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        colors.onSurface,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .star_rounded,
                          color:
                          AppColors.gold,
                          size: 16,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          product.rating
                              .toStringAsFixed(
                            1,
                          ),
                          style:
                          GoogleFonts
                              .inter(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w700,
                            color:
                            colors.onSurface,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Flexible(
                          child: Text(
                            '(${product.reviewCount})',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            GoogleFonts
                                .inter(
                              fontSize: 11,
                              color:
                              colors
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _formatPrice(
                              product.discountPrice ?? product.price,
                            ),
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            GoogleFonts
                                .inter(
                              fontSize: 15,
                              fontWeight:
                              FontWeight
                                  .w800,
                              color:
                              AppColors
                                  .gold,
                            ),
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(
                            width: 6,
                          ),
                          Flexible(
                            child: Text(
                              _formatPrice(
                                product.price,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              GoogleFonts
                                  .inter(
                                fontSize: 11,
                                color: colors
                                    .onSurfaceVariant,
                                decoration:
                                TextDecoration
                                    .lineThrough,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(
                          width: 4,
                        ),
                        _AddToCartButton(
                          product: product,
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
    );
  }
}

// ============================================================
// PRODUCT IMAGE
// ============================================================

class _ProductImage
    extends StatelessWidget {
  const _ProductImage({
    required this.product,
    required this.isArabic,
  });

  final Product product;
  final bool isArabic;

  @override
  Widget build(
      BuildContext context,
      ) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(context),

          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                if (product.isNew)
                  _productBadge(
                    isArabic
                        ? 'جديد'
                        : 'NEW',
                    AppColors.gold,
                  ),
                if (product.isNew &&
                    product.hasDiscount)
                  const SizedBox(
                    width: 6,
                  ),
                if (product.hasDiscount)
                  _productBadge(
                    '-${product.discountPercent.round()}%',
                    Colors.black
                        .withValues(
                      alpha: 0.7,
                    ),
                  ),
              ],
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child:
            _FavoriteButton(
              product: product,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(
      BuildContext context,
      ) {
    if (product.images.isEmpty) {
      return _fallbackImage();
    }

    final imageUrl =
        product.images.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      maxWidthDiskCache: 600,
      memCacheWidth: 400,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          color: Colors.white,
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: AppColors.gold,
              size: 24,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Container(
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            AppColors.goldDark,
            Colors.grey,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FAVORITE BUTTON
// ============================================================

class _FavoriteButton
    extends StatelessWidget {
  const _FavoriteButton({
    required this.product,
  });

  final Product product;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Consumer<
        FavoritesProvider>(
      builder:
          (context, favorites, child) {
        final active =
        favorites.isFavorite(
          product.id,
        );

        return GestureDetector(
          onTap: () {
            favorites.toggleFavorite(
              product,
            );
          },
          child:
          AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 250,
            ),
            width: 32,
            height: 32,
            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              color: Colors.white
                  .withValues(
                alpha: 0.92,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              active
                  ? Icons
                  .favorite_rounded
                  : Icons
                  .favorite_border_rounded,
              size: 17,
              color: active
                  ? AppColors
                  .lightError
                  : AppColors.black,
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// ADD TO CART BUTTON
// ============================================================

class _AddToCartButton
    extends StatelessWidget {
  const _AddToCartButton({
    required this.product,
  });

  final Product product;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Consumer<CartProvider>(
      builder:
          (context, cart, child) {
        final inCart =
        cart.isInCart(
          product.id,
        );

        return GestureDetector(
          onTap: () {
            if (!inCart) {
              String? selectedColor;

              if (product.colors
                  .isNotEmpty) {
                final value =
                product.colors
                    .first
                    .toARGB32()
                    .toRadixString(
                  16,
                )
                    .padLeft(
                  8,
                  '0',
                );

                selectedColor =
                '#${value.substring(2).toUpperCase()}';
              }

              cart.addItem(
                product,
                color:
                selectedColor,
              );
            }
          },
          child:
          AnimatedContainer(
            duration:
            const Duration(
              milliseconds: 250,
            ),
            width: 32,
            height: 32,
            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              color: inCart
                  ? AppColors.gold
                  : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHigh,
              border:
              Border.all(
                color: AppColors.gold
                    .withValues(
                  alpha: 0.4,
                ),
              ),
            ),
            child: Icon(
              inCart
                  ? Icons
                  .check_rounded
                  : Icons
                  .shopping_bag_outlined,
              size: 16,
              color: inCart
                  ? AppColors.black
                  : AppColors.gold,
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

IconData _categoryIconForEnum(
    Category category,
    ) {
  switch (category) {
    case Category.men:
      return Icons.man_rounded;

    case Category.women:
      return Icons.woman_rounded;

    case Category.kids:
      return Icons.child_care_rounded;

    case Category.shoes:
      return Icons.directions_walk_rounded;

    case Category.bags:
      return Icons.shopping_bag_rounded;

    case Category.accessories:
      return Icons.watch_rounded;
  }
}

IconData _productIcon(
    Category category,
    ) {
  switch (category) {
    case Category.men:
      return Icons.man_rounded;

    case Category.women:
      return Icons.woman_rounded;

    case Category.kids:
      return Icons.child_care_rounded;

    case Category.shoes:
      return Icons.directions_walk_rounded;

    case Category.bags:
      return Icons.shopping_bag_rounded;

    case Category.accessories:
      return Icons.watch_rounded;
  }
}

Widget _productBadge(
    String text,
    Color color,
    ) {
  return Container(
    padding:
    const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 5,
    ),
    decoration:
    BoxDecoration(
      color: color,
      borderRadius:
      BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight:
        FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

String _formatPrice(
    double value,
    ) {
  return value.toStringAsFixed(
    value % 1 == 0 ? 0 : 2,
  );
}