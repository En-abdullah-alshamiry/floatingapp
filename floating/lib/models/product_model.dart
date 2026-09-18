import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final double? discountPercent;
  final String? categoryId;
  final List<String> images;
  final List<String> colors;
  final List<String> colorHex;
  final List<String> sizes;
  final bool isNew;
  final bool isBestSeller;
  final bool hasDiscount;
  final Timestamp? dateAdded;

  const ProductModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.discountPercent,
    this.categoryId,
    this.images = const [],
    this.colors = const [],
    this.colorHex = const [],
    this.sizes = const [],
    this.isNew = false,
    this.isBestSeller = false,
    this.hasDiscount = false,
    this.dateAdded,
  });

  // ============================================================
  // تحويل ProductModel إلى Map لـ Firestore
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'price': price,
      'discountPercent': discountPercent,
      'categoryId': categoryId,
      'images': images,
      'colors': colors,
      'colorHex': colorHex,
      'sizes': sizes,
      'isNew': isNew,
      'isBestSeller': isBestSeller,
      'hasDiscount': hasDiscount,
      'dateAdded': dateAdded,
    };
  }

  // ============================================================
  // إنشاء ProductModel من Firestore
  // ============================================================

  factory ProductModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return ProductModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      nameAr: data['nameAr']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      descriptionAr: data['descriptionAr']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      discountPercent:
      (data['discountPercent'] as num?)?.toDouble(),
      categoryId: data['categoryId']?.toString(),
      images: _stringList(data['images']),
      colors: _stringList(data['colors']),
      colorHex: _stringList(data['colorHex']),
      sizes: _stringList(data['sizes']),
      isNew: data['isNew'] == true,
      isBestSeller: data['isBestSeller'] == true,
      hasDiscount: data['hasDiscount'] == true,
      dateAdded: data['dateAdded'] is Timestamp
          ? data['dateAdded'] as Timestamp
          : null,
    );
  }

  // ============================================================
  // تحويل أي List إلى List<String> بأمان
  // ============================================================

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // ============================================================
  // تحديث نسخة من المنتج
  // ============================================================

  ProductModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    double? discountPercent,
    String? categoryId,
    List<String>? images,
    List<String>? colors,
    List<String>? colorHex,
    List<String>? sizes,
    bool? isNew,
    bool? isBestSeller,
    bool? hasDiscount,
    Timestamp? dateAdded,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      discountPercent:
      discountPercent ?? this.discountPercent,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
      colors: colors ?? this.colors,
      colorHex: colorHex ?? this.colorHex,
      sizes: sizes ?? this.sizes,
      isNew: isNew ?? this.isNew,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}