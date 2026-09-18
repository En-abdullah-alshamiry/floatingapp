import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../config/app_colors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImage = 0;
  int _quantity = 1;
  Color? _selectedColor;
  String? _selectedSize;

  Product get product => widget.product;

  double get currentPrice => product.discountPrice ?? product.price;

  @override
  void initState() {
    super.initState();

    if (product.colors.isNotEmpty) {
      _selectedColor = product.colors.first;
    }

    if (product.sizes.isNotEmpty) {
      _selectedSize = product.sizes.first;
    }
  }
  void _addToCart() {
    String? selectedColor;

    if (_selectedColor != null) {
      final value = _selectedColor!
          .toARGB32()
          .toRadixString(16)
          .padLeft(8, '0');

      selectedColor =
      '#${value.substring(2).toUpperCase()}';
    }

    context.read<CartProvider>().addItem(
      product,
      color: selectedColor,
      size: _selectedSize,
      qty: _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تمت إضافة المنتج إلى السلة',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            if (isWide) {
              return Column(
                children: [
                  _buildWideAppBar(context, theme),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            child: _buildGallery(context),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: _buildProductDetails(theme, isDark, true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGallery(context),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: _buildProductDetails(theme, isDark, false),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideAppBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(ThemeData theme, bool isDark, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategory(theme),
        const SizedBox(height: 12),
        Text(
          product.displayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        _buildPrice(theme),
        const SizedBox(height: 16),
        if (product.descriptionAr.isNotEmpty || product.descriptionEn.isNotEmpty)
          _buildDescription(theme),
        const SizedBox(height: 24),
        if (product.sizes.isNotEmpty) ...[
          _buildSizes(theme),
          const SizedBox(height: 24),
        ],
        if (product.colors.isNotEmpty) ...[
          _buildColors(theme),
          const SizedBox(height: 24),
        ],
        _buildQuantity(theme),
        const SizedBox(height: 32),
        _buildAddToCartButton(theme),
        const SizedBox(height: 20),
        _buildProductInfo(theme, isDark),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGallery(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final galleryHeight = screenWidth > 900
            ? 600.0
            : screenWidth > 600
                ? 500.0
                : 390.0;

        if (product.images.isEmpty) {
          return Container(
            height: galleryHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surfaceContainerHighest,
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 80,
              ),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: galleryHeight,
              child: PageView.builder(
                itemCount: product.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = product.images[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 70,
                          ),
                        ),
                      ),
                    ),

                  );
                },
              ),
            ),
            if (product.images.length > 1) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.images.length,
                      (index) {
                    final selected = index == _currentImage;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 7,
                      width: selected ? 22 : 7,
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCategory(ThemeData theme) {
    return Text(
      product.category.arName,
      style: theme.textTheme.titleMedium?.copyWith(
        color: AppColors.gold,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRating(ThemeData theme) {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          color: Colors.amber,
          size: 22,
        ),
        const SizedBox(width: 5),
        Text(
          product.rating.toStringAsFixed(1),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (product.reviewCount > 0) ...[
          const SizedBox(width: 6),
          Text(
            '(${product.reviewCount} تقييم)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrice(ThemeData theme) {
    final hasDiscount = product.hasDiscount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${currentPrice.toStringAsFixed(0)} ر.س',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 12),
          Text(
            '${product.price.toStringAsFixed(0)} ر.س',
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    final description = product.descriptionAr.isNotEmpty
        ? product.descriptionAr
        : product.descriptionEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوصف',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.7,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildColors(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اللون',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: product.colors.map((color) {
            final selected = _selectedColor?.toARGB32() == color.toARGB32();

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.4),
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizes(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المقاس',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: product.sizes.map((size) {
            final selected = _selectedSize == size;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.gold
                      : (isDark ? const Color(0xFF1E1E1E) : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.gold
                        : (isDark ? Colors.white12 : Colors.grey[300]!),
                  ),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: selected
                        ? Colors.black
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantity(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الكمية',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                },
                icon: const Icon(Icons.add, color: AppColors.gold),
              ),
              Text(
                '$_quantity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _quantity > 1
                    ? () {
                  setState(() {
                    _quantity--;
                  });
                }
                    : null,
                icon: const Icon(Icons.remove, color: AppColors.gold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        // زر المفضلة
        Container(
          width: 56,
          height: 60,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite, color: AppColors.gold),
          ),
        ),
        const SizedBox(width: 12),
        // زر إضافة للسلة
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: product.available ? _addToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      product.available
                          ? 'أضيفي إلى السلة — ${currentPrice.toStringAsFixed(0)} ر.س'
                          : 'المنتج غير متوفر',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.35 : 0.5,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _infoRow(
            theme,
            Icons.local_shipping_outlined,
            'الشحن',
            'شحن سريع وآمن',
          ),
          const Divider(height: 24),
          _infoRow(
            theme,
            Icons.verified_outlined,
            'الجودة',
            'منتجات مختارة بعناية',
          ),
          const Divider(height: 24),
          _infoRow(
            theme,
            Icons.assignment_return_outlined,
            'الإرجاع',
            'إمكانية الإرجاع حسب سياسة المتجر',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      ThemeData theme,
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}