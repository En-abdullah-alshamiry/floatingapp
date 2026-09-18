class OnboardingItem {
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String image;

  const OnboardingItem({
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.image,
  });

  String get displayTitle => titleAr.isNotEmpty ? titleAr : titleEn;

  String get displayDescription =>
      descriptionAr.isNotEmpty ? descriptionAr : descriptionEn;

  OnboardingItem copyWith({
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    String? image,
  }) {
    return OnboardingItem(
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'image': image,
    };
  }

  factory OnboardingItem.fromJson(Map<String, dynamic> json) {
    return OnboardingItem(
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  static List<OnboardingItem> defaultItems = const [
    OnboardingItem(
      titleAr: 'اكتشف أحدث صيحات الموضة',
      titleEn: 'Discover Latest Fashion Trends',
      descriptionAr:
          'تصفح مجموعتنا الحصرية من الملابس والإكسسوارات العصرية لجميع المناسبات',
      descriptionEn:
          'Browse our exclusive collection of trendy clothing and accessories for all occasions',
      image: 'https://picsum.photos/seed/fashion1/600/800',
    ),
    OnboardingItem(
      titleAr: 'تسوّق بذكاء وراحة',
      titleEn: 'Shop Smart & Easy',
      descriptionAr:
          'تجربة تسوّق سلسة مع فلاتر ذكية ومقاسات دقيقة وتوصيل سريع لباب بيتك',
      descriptionEn:
          'Seamless shopping experience with smart filters, accurate sizing, and fast delivery',
      image: 'https://picsum.photos/seed/fashion2/600/800',
    ),
    OnboardingItem(
      titleAr: 'الأناقة تبدأ من هنا',
      titleEn: 'Elegance Starts Here',
      descriptionAr:
          'سجّل الآن واحصل على خصم 20% على طلبك الأول مع توصيل مجاني',
      descriptionEn:
          'Sign up now and get 20% off your first order with free shipping',
      image: 'https://picsum.photos/seed/fashion3/600/800',
    ),
  ];
}
