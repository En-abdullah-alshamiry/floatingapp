import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductGridShimmer extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  const ProductGridShimmer({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.62,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _ShimmerPalette.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: colors.base,
        highlightColor: colors.highlight,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => const _ShimmerProductCard(),
        ),
      ),
    );
  }
}

class ProductListShimmer extends StatelessWidget {
  final int itemCount;

  const ProductListShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final colors = _ShimmerPalette.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: colors.base,
        highlightColor: colors.highlight,
        child: Column(
          children: List.generate(
            itemCount,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const _ShimmerBox(width: 96, height: 112, radius: 16),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _ShimmerBox(height: 14, radius: 7),
                        SizedBox(height: 12),
                        FractionallySizedBox(
                          widthFactor: 0.6,
                          child: _ShimmerBox(height: 12, radius: 6),
                        ),
                        SizedBox(height: 12),
                        FractionallySizedBox(
                          widthFactor: 0.4,
                          child: _ShimmerBox(height: 12, radius: 6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: SizedBox.expand(
              child: _ShimmerBox(radius: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ShimmerBox(height: 14, radius: 7),
                SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: _ShimmerBox(height: 12, radius: 6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const _ShimmerBox({
    this.width,
    this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _ShimmerPalette.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            colors.base,
            colors.base.withValues(alpha: 0.55),
            colors.base,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _ShimmerPalette {
  final Color base;
  final Color highlight;

  const _ShimmerPalette({required this.base, required this.highlight});

  static _ShimmerPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const _ShimmerPalette(
            base: Color(0xFF2A2A2A),
            highlight: Color(0xFF3D3D3D),
          )
        : const _ShimmerPalette(
            base: Color(0xFFE7E2DC),
            highlight: Color(0xFFF4F1ED),
          );
  }
}