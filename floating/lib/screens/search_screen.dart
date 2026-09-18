import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/locale_provider.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../config/app_colors.dart';

String _price(double amount, AppLocalizations l10n) =>
    '${amount.toStringAsFixed(2)} ${l10n.tr('currency')}';

TextStyle _headingStyle(
    Color color,
    double size, {
      required bool isRTL,
    }) {
  if (isRTL) {
    return GoogleFonts.notoSansArabic(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
  );
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _focusNode = FocusNode();

  final List<String> _recentSearches = <String>[];

  late Box _searchBox;

  String _query = '';

  List<Product> _results = [];

  bool _isLoading = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _searchBox = Hive.box('search_box');

    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final savedSearches = _searchBox.values
        .whereType<String>()
        .toList();

    if (!mounted) return;

    setState(() {
      _recentSearches.clear();
      _recentSearches.addAll(
        savedSearches.take(6),
      );
    });
  }

  Future<void> _saveRecentSearches() async {
    await _searchBox.clear();

    for (final search in _recentSearches) {
      await _searchBox.add(search);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _setQuery(String value) async {
    final trimmed = value.trim();

    _searchController.text = value;

    _searchController.selection =
        TextSelection.collapsed(
          offset: value.length,
        );

    setState(() {
      _query = trimmed;
      _error = null;
    });

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);

    if (_recentSearches.length > 6) {
      _recentSearches.removeLast();
    }

    await _saveRecentSearches();

    await _searchProducts(trimmed);
  }

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products =
      await ApiService.instance.searchProducts(query);

      if (!mounted) return;

      setState(() {
        _results = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _results = [];
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _clearQuery() {
    _searchController.clear();

    setState(() {
      _query = '';
      _results = [];
      _error = null;
      _isLoading = false;
    });

    _focusNode.requestFocus();
  }

  Future<void> _clearRecentSearches() async {
    _recentSearches.clear();

    await _searchBox.clear();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeRecentSearch(int index) async {
    if (index < 0 ||
        index >= _recentSearches.length) {
      return;
    }

    _recentSearches.removeAt(index);

    await _saveRecentSearches();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider =
    Provider.of<LocaleProvider>(context);

    final isRTL = localeProvider.isRTL;

    final l10n =
    AppLocalizations.of(context);

    final cs =
        Theme.of(context).colorScheme;

    final searching = _query.isNotEmpty;

    return Directionality(
      textDirection:
      isRTL
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.tr('search_title'),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  8,
                ),
                child: TextField(
                  controller:
                  _searchController,
                  focusNode: _focusNode,
                  autofocus: true,
                  textInputAction:
                  TextInputAction.search,
                  onSubmitted: _setQuery,
                  onChanged: (value) {
                    setState(() {
                      _query =
                          value.trim();
                    });
                  },
                  decoration:
                  InputDecoration(
                    hintText:
                    l10n.tr(
                      'search_hint',
                    ),
                    prefixIcon:
                    const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                    _query.isNotEmpty
                        ? IconButton(
                      icon:
                      const Icon(
                        Icons.close,
                      ),
                      onPressed:
                      _clearQuery,
                    )
                        : null,
                  ),
                ),
              ),

              Expanded(
                child: searching
                    ? _buildResults(
                  context,
                  isRTL,
                  l10n,
                  cs,
                )
                    : _buildSuggestions(
                  context,
                  isRTL,
                  l10n,
                  cs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return ListView(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.tr(
                    'recent_searches',
                  ),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed:
                _clearRecentSearches,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                ),
                label: Text(
                  l10n.tr('clear_all'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            decoration:
            BoxDecoration(
              color: cs.surface,
              borderRadius:
              BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  cs.shadow.withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 12,
                  offset:
                  const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children:
              List.generate(
                _recentSearches.length,
                    (index) {
                  final term =
                  _recentSearches[
                  index];

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.history,
                      color:
                      cs.onSurfaceVariant,
                    ),
                    title: Text(term),
                    trailing:
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 16,
                        color:
                        cs.onSurfaceVariant,
                      ),
                      onPressed: () =>
                          _removeRecentSearch(
                            index,
                          ),
                    ),
                    onTap: () =>
                        _setQuery(term),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],

        Text(
          l10n.tr('popular_searches'),
          style: _headingStyle(
            cs.onSurface,
            16,
            isRTL: isRTL,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'استخدم البحث للعثور على المنتجات من API',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildResults(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError(
        context,
        l10n,
        cs,
      );
    }

    if (_results.isEmpty) {
      return _buildEmpty(
        context,
        l10n,
        cs,
      );
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:
          const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            8,
          ),
          child: Text(
            '${l10n.tr('showing')} ${_results.length} ${l10n.tr('results')}',
            style: TextStyle(
              color:
              cs.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              16,
            ),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.64,
            ),
            itemCount:
            _results.length,
            itemBuilder:
                (context, index) {
              return _ProductCard(
                product:
                _results[index],
                isRTL: isRTL,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildError(
      BuildContext context,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .wifi_off_rounded,
              size: 60,
              color:
              cs.onSurfaceVariant,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'تعذر تحميل المنتجات',
              style:
              _headingStyle(
                cs.onSurface,
                20,
                isRTL: true,
              ),
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'تأكد من اتصال الإنترنت ثم حاول مرة أخرى.',
              style: TextStyle(
                color:
                cs.onSurfaceVariant,
              ),
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton.icon(
              onPressed:
                  () => _searchProducts(
                _query,
              ),
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(
      BuildContext context,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration:
              BoxDecoration(
                gradient:
                AppColors.darkGradient,
                shape:
                BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                    cs.shadow.withValues(
                      alpha: 0.6,
                    ),
                    blurRadius: 16,
                    offset:
                    const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),
              child:
              const Icon(
                Icons.search_off,
                size: 40,
                color:
                AppColors.gold,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              l10n.tr(
                'search_empty',
              ),
              style: _headingStyle(
                cs.onSurface,
                22,
                isRTL: true,
              ),
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              l10n.tr(
                'search_empty_desc',
              ),
              style: TextStyle(
                color:
                cs.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(
              height: 24,
            ),

            OutlinedButton.icon(
              onPressed:
              _clearQuery,
              icon:
              const Icon(
                Icons.refresh,
              ),
              label: Text(
                l10n.tr(
                  'clear_all',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard
    extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isRTL,
  });

  final Product product;
  final bool isRTL;

  String get _name =>
      isRTL
          ? product.nameAr
          : product.nameEn;

  @override
  Widget build(
      BuildContext context,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    final l10n =
    AppLocalizations.of(
      context,
    );

    final favorites =
    Provider.of<FavoritesProvider>(
      context,
    );

    final cart =
    Provider.of<CartProvider>(
      context,
    );

    final base =
    product.colors.isNotEmpty
        ? product.colors.first
        : cs.primary;

    final isFav =
    favorites.isFavorite(
      product.id,
    );

    return Container(
      decoration:
      BoxDecoration(
        color: cs.surface,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
          cs.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color:
            cs.shadow.withValues(
              alpha: 0.5,
            ),
            blurRadius: 14,
            offset:
            const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior:
      Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (product
                    .images
                    .isNotEmpty)
                  Image.network(
                    product
                        .images
                        .first,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {
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

                if (product
                    .hasDiscount)
                  Positioned(
                    top: 8,
                    left: isRTL
                        ? null
                        : 8,
                    right: isRTL
                        ? 8
                        : null,
                    child:
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal:
                        8,
                        vertical: 4,
                      ),
                      decoration:
                      BoxDecoration(
                        gradient:
                        AppColors
                            .saleGradient,
                        borderRadius:
                        BorderRadius
                            .circular(
                          10,
                        ),
                      ),
                      child:
                      Text(
                        '-${product.discountPercent.round()}%',
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize:
                          11,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 8,
                  right: isRTL
                      ? null
                      : 8,
                  left: isRTL
                      ? 8
                      : null,
                  child:
                  _CircleButton(
                    icon: isFav
                        ? Icons
                        .favorite
                        : Icons
                        .favorite_border,
                    color: isFav
                        ? AppColors
                        .lightError
                        : cs
                        .onSurfaceVariant,
                    onTap: () {
                      favorites
                          .toggleFavorite(
                        product,
                      );

                      ScaffoldMessenger
                          .of(
                        context,
                      )
                          .showSnackBar(
                        SnackBar(
                          content:
                          Text(
                            isFav
                                ? l10n.tr(
                              'remove_from_wishlist',
                            )
                                : l10n.tr(
                              'add_to_wishlist',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
            const EdgeInsets
                .fromLTRB(
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
                  _name,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight
                        .w600,
                    fontSize: 14,
                    color:
                    cs.onSurface,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            _price(
                              product
                                  .discountPrice ??
                                  product
                                      .price,
                              l10n,
                            ),
                            style:
                            const TextStyle(
                              color:
                              AppColors
                                  .gold,
                              fontWeight:
                              FontWeight
                                  .w700,
                              fontSize:
                              14,
                            ),
                          ),

                          if (product
                              .hasDiscount)
                            Text(
                              _price(
                                product
                                    .price,
                                l10n,
                              ),
                              style:
                              TextStyle(
                                color:
                                cs.onSurfaceVariant,
                                fontSize:
                                11,
                                decoration:
                                TextDecoration
                                    .lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    _CircleButton(
                      icon: Icons
                          .add_shopping_cart,
                      color:
                      AppColors
                          .gold,
                      onTap: () {
                        final selectedColor =
                        product
                            .colors
                            .isEmpty
                            ? null
                            : _colorToHex(
                          product
                              .colors
                              .first,
                        );

                        final selectedSize =
                        product
                            .sizes
                            .isEmpty
                            ? null
                            : product
                            .sizes
                            .first;

                        cart.addItem(
                          product,
                          color:
                          selectedColor,
                          size:
                          selectedSize,
                        );

                        ScaffoldMessenger
                            .of(
                          context,
                        )
                            .showSnackBar(
                          SnackBar(
                            content:
                            Text(
                              l10n.tr(
                                'added_to_cart',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(
      BuildContext context,
      Color base,
      ) {
    final cs =
        Theme.of(context)
            .colorScheme;

    return Container(
      decoration:
      BoxDecoration(
        gradient:
        LinearGradient(
          colors: [
            base.withValues(
              alpha: 0.30,
            ),
            base.withValues(
              alpha: 0.10,
            ),
            cs.surfaceContainerLowest,
          ],
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
        ),
      ),
      child: Icon(
        _categoryIcon(
          product.category,
        ),
        size: 48,
        color: base.withValues(
          alpha: 0.7,
        ),
      ),
    );
  }
}

class _CircleButton
    extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: color.withValues(
        alpha: 0.12,
      ),
      shape:
      const CircleBorder(),
      child: InkWell(
        customBorder:
        const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(
            8,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}