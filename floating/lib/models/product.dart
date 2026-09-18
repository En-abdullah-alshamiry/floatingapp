import 'package:flutter/material.dart';

enum Category {
  men,
  women,
  kids,
  shoes,
  bags,
  accessories;

  String get arName {
    switch (this) {
      case Category.men:
        return 'رجال';
      case Category.women:
        return 'نساء';
      case Category.kids:
        return 'أطفال';
      case Category.shoes:
        return 'أحذية';
      case Category.bags:
        return 'حقائب';
      case Category.accessories:
        return 'إكسسوارات';
    }
  }

  String get enName {
    switch (this) {
      case Category.men:
        return 'Men';
      case Category.women:
        return 'Women';
      case Category.kids:
        return 'Kids';
      case Category.shoes:
        return 'Shoes';
      case Category.bags:
        return 'Bags';
      case Category.accessories:
        return 'Accessories';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.men:
        return Icons.man_outlined;
      case Category.women:
        return Icons.woman_outlined;
      case Category.kids:
        return Icons.child_care_outlined;
      case Category.shoes:
        return Icons.shopping_bag_outlined;
      case Category.bags:
        return Icons.work_outline;
      case Category.accessories:
        return Icons.watch_outlined;
    }
  }

  String get imageUrl {
    switch (this) {
      case Category.men:
        return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80';
      case Category.women:
        return 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80';
      case Category.kids:
        return 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=200&q=80';
      case Category.shoes:
        return 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=200&q=80';
      case Category.bags:
        return 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=200&q=80';
      case Category.accessories:
        return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=200&q=80';
    }
  }

  static Category fromString(String? value) {
    if (value == null || value.isEmpty) {
      return Category.women;
    }

    final normalized = value.toLowerCase().trim();

    switch (normalized) {
      case 'men':
      case 'mens':
      case 'men clothing':
      case 'رجال':
      case 'ملابس رجالية':
        return Category.men;

      case 'women':
      case 'womens':
      case 'women clothing':
      case 'نساء':
      case 'ملابس نسائية':
        return Category.women;

      case 'kids':
      case 'kid':
      case 'children':
      case 'أطفال':
        return Category.kids;

      case 'shoes':
      case 'أحذية':
        return Category.shoes;

      case 'bags':
      case 'حقائب':
        return Category.bags;

      case 'accessories':
      case 'إكسسوارات':
        return Category.accessories;

      default:
        return Category.women;
    }
  }
}

class Product {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final Category category;
  final List<Color> colors;
  final List<String> sizes;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isBestSeller;
  final bool isFavorite;
  final bool available;

  const Product({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    this.discountPrice,
    this.images = const [],
    required this.category,
    this.colors = const [],
    this.sizes = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isNew = false,
    this.isBestSeller = false,
    this.isFavorite = false,
    this.available = true,
  });

  // ============================================================
  // الخصم
  // ============================================================

  bool get hasDiscount {
    return discountPrice != null &&
        discountPrice! < price &&
        price > 0;
  }

  double get discountPercent {
    if (!hasDiscount || price <= 0) {
      return 0;
    }

    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  // ============================================================
  // الاسم والوصف
  // ============================================================

  String get displayName {
    return nameAr.isNotEmpty ? nameAr : nameEn;
  }

  String get displayDescription {
    return descriptionAr.isNotEmpty
        ? descriptionAr
        : descriptionEn;
  }

  // ============================================================
  // نسخ المنتج
  // ============================================================

  Product copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? price,
    double? discountPrice,
    List<String>? images,
    Category? category,
    List<Color>? colors,
    List<String>? sizes,
    double? rating,
    int? reviewCount,
    bool? isNew,
    bool? isBestSeller,
    bool? isFavorite,
    bool? available,
  }) {
    return Product(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isNew: isNew ?? this.isNew,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isFavorite: isFavorite ?? this.isFavorite,
      available: available ?? this.available,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'category': category.name,
      'colors': colors.map((color) => color.toARGB32()).toList(),
      'sizes': sizes,
      'rating': rating,
      'reviewCount': reviewCount,
      'isNew': isNew,
      'isBestSeller': isBestSeller,
      'isFavorite': isFavorite,
      'available': available,
    };
  }

  // ============================================================
  // إنشاء Product من JSON
  // ============================================================

  factory Product.fromJson(Map<String, dynamic> json) {
    final dynamic rawImages = json['images'];

    final List<String> images = rawImages is List
        ? rawImages
        .map((image) => image.toString())
        .where((image) => image.isNotEmpty)
        .toList()
        : [];

    final dynamic rawColors = json['colors'];

    final List<Color> colors = rawColors is List
        ? rawColors
        .whereType<num>()
        .map((value) => Color(value.toInt()))
        .toList()
        : [];

    final dynamic rawSizes = json['sizes'];

    final List<String> sizes = rawSizes is List
        ? rawSizes.map((size) => size.toString()).toList()
        : [];

    return Product(
      id: json['id']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      descriptionAr: json['descriptionAr']?.toString() ?? '',
      descriptionEn: json['descriptionEn']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice:
      (json['discountPrice'] as num?)?.toDouble(),
      images: images,
      category: Category.fromString(
        json['category']?.toString(),
      ),
      colors: colors,
      sizes: sizes,
      rating:
      (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:
      (json['reviewCount'] as num?)?.toInt() ?? 0,
      isNew: json['isNew'] as bool? ?? false,
      isBestSeller:
      json['isBestSeller'] as bool? ?? false,
      isFavorite:
      json['isFavorite'] as bool? ?? false,
      available:
      json['available'] as bool? ?? true,
    );
  }
}