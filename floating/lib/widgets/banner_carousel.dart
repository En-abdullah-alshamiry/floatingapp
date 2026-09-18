import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

/// بيانات البنر
class BannerItem {
const BannerItem({
required this.titleAr,
required this.titleEn,
required this.subtitleAr,
required this.subtitleEn,
required this.image,
this.discountCode,
});

final String titleAr;
final String titleEn;
final String subtitleAr;
final String subtitleEn;
final String image;
final String? discountCode;
}

/// البنرات الافتراضية
const List<BannerItem> defaultBanners = [

  BannerItem(
    titleAr: 'أناقة جديدة، هوية جديدة',
    titleEn: 'Beauty Touch',
    subtitleAr: 'اكتشف أحدث أدوات التجميل',
    subtitleEn: 'Discover our latest beauty tools',
    image: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=800',
    discountCode: 'GLOW15',
  ),
  BannerItem(
    titleAr: 'خصومات حصرية',
    titleEn: 'Exclusive Offers',
    subtitleAr: 'استمتع بخصم مميز لفترة محدودة',
    subtitleEn: 'Enjoy a special limited-time discount',
    image: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=800',
    discountCode: 'SALE30',
  ),
  BannerItem(
    titleAr: 'تسوق بإطلالة مختلفة',
    titleEn: 'Shop Your New Look',
    subtitleAr: 'اختيارات مميزة تناسب ذوقك',
    subtitleEn: 'Premium picks made for your style',
    image: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=800',
  ),
];

class BannerCarousel extends StatefulWidget {
const BannerCarousel({
super.key,
this.height = 208,
this.banners,
this.autoPlay = true,
});

final double height;
final List<BannerItem>? banners;
final bool autoPlay;

@override
State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
final PageController _controller = PageController(
viewportFraction: 0.94,
);

Timer? _timer;
int _current = 0;

List<BannerItem> get _items {
return widget.banners ?? defaultBanners;
}

@override
void initState() {
super.initState();

if (widget.autoPlay && _items.length > 1) {
_timer = Timer.periodic(
const Duration(seconds: 4),
(_) {
if (!mounted || _items.isEmpty) return;

final next = (_current + 1) % _items.length;

_controller.animateToPage(
next,
duration: const Duration(milliseconds: 600),
curve: Curves.easeInOutCubic,
);
},
);
}
}

@override
void dispose() {
_timer?.cancel();
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final l10n = AppLocalizations.of(context);

if (_items.isEmpty) {
return SizedBox(
height: widget.height,
);
}

return SizedBox(
height: widget.height,
child: Column(
children: [
Expanded(
child: PageView.builder(
controller: _controller,
itemCount: _items.length,
onPageChanged: (index) {
if (mounted) {
setState(() {
_current = index;
});
}
},
itemBuilder: (context, index) {
final banner = _items[index];

return Padding(
padding: const EdgeInsets.symmetric(
horizontal: 6,
),
child: _BannerCard(
title: l10n.isArabic
? banner.titleAr
    : banner.titleEn,
subtitle: l10n.isArabic
? banner.subtitleAr
    : banner.subtitleEn,
discountCode: banner.discountCode,
imagePath: banner.image,
isSale: banner.discountCode != null,
),
);
},
),
),
const SizedBox(height: 12),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: List.generate(
_items.length,
(index) {
final active = index == _current;

return AnimatedContainer(
duration: const Duration(
milliseconds: 300,
),
margin: const EdgeInsets.symmetric(
horizontal: 3,
),
width: active ? 20 : 6,
height: 6,
decoration: BoxDecoration(
color: active
? AppColors.gold
    : Colors.grey.withValues(
alpha: 0.4,
),
borderRadius: BorderRadius.circular(3),
),
);
},
),
),
],
),
);
}
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isSale,
    this.discountCode,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String? discountCode;
  final bool isSale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final isRtl =
        Directionality.of(context) == TextDirection.rtl;

    final gradient = isSale
        ? AppColors.saleGradient
        : const LinearGradient(
      colors: [
        Color(0xFFD4AF37),
        Color(0xFF9C7A1E),
        Color(0xFF241E16),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.18,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [

          /// صورة البنر
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: imagePath,
              fit: BoxFit.cover,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),

          /// طبقة شفافة فوق الصورة
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.18,
                    ),
                    Colors.black.withValues(
                      alpha: 0.62,
                    ),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          /// دائرة زخرفية علوية
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),

          /// دائرة زخرفية سفلية
          Positioned(
            left: -32,
            bottom: -56,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
          ),

          /// محتوى البنر
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;

                // ضبط الحشوات والخطوط ديناميكياً لتجنب Overflow
                final padding = (h * 0.07).clamp(10.0, 18.0);
                final titleSize = (h * 0.09).clamp(15.0, 20.0);
                final subtitleSize = (h * 0.055).clamp(10.0, 12.0);
                final spacing = (h * 0.025).clamp(4.0, 6.0);

                return Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// كود الخصم
                      if (discountCode != null && h > 160) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            discountCode!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      /// العنوان
                      Text(
                        title,
                        maxLines: h < 140 ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),

                      if (h > 170) ...[
                        SizedBox(height: spacing / 2),
                        /// الوصف
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: subtitleSize,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.2,
                          ),
                        ),
                      ],

                      SizedBox(height: spacing),

                      /// زر تسوق الآن
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.isArabic ? 'تسوق الآن' : 'Shop Now',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: (h * 0.065).clamp(11.0, 13.0),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isRtl
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                            size: (h * 0.08).clamp(14.0, 16.0),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}