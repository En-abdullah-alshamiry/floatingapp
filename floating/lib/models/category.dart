class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;
  final String imagePlaceholder;
  final int productCount;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.imagePlaceholder,
    this.productCount = 0,
  });

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  CategoryModel copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? icon,
    String? imagePlaceholder,
    int? productCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      imagePlaceholder: imagePlaceholder ?? this.imagePlaceholder,
      productCount: productCount ?? this.productCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'icon': icon,
      'imagePlaceholder': imagePlaceholder,
      'productCount': productCount,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      imagePlaceholder: json['imagePlaceholder'] as String? ?? '',
      productCount: json['productCount'] as int? ?? 0,
    );
  }

  static List<CategoryModel> defaultCategories = [
    const CategoryModel(
      id: '1',
      nameAr: 'رجال',
      nameEn: 'Men',
      icon: 'man',
      imagePlaceholder: 'https://picsum.photos/seed/men/300/300',
      productCount: 120,
    ),
    const CategoryModel(
      id: '2',
      nameAr: 'نساء',
      nameEn: 'Women',
      icon: 'woman',
      imagePlaceholder: 'https://picsum.photos/seed/women/300/300',
      productCount: 245,
    ),
    const CategoryModel(
      id: '3',
      nameAr: 'أطفال',
      nameEn: 'Kids',
      icon: 'child',
      imagePlaceholder: 'https://picsum.photos/seed/kids/300/300',
      productCount: 85,
    ),
    const CategoryModel(
      id: '4',
      nameAr: 'أحذية',
      nameEn: 'Shoes',
      icon: 'shoe',
      imagePlaceholder: 'https://picsum.photos/seed/shoes/300/300',
      productCount: 160,
    ),
    const CategoryModel(
      id: '5',
      nameAr: 'حقائب',
      nameEn: 'Bags',
      icon: 'bag',
      imagePlaceholder: 'https://picsum.photos/seed/bags/300/300',
      productCount: 95,
    ),
    const CategoryModel(
      id: '6',
      nameAr: 'إكسسوارات',
      nameEn: 'Accessories',
      icon: 'accessory',
      imagePlaceholder: 'https://picsum.photos/seed/accessories/300/300',
      productCount: 130,
    ),
  ];
}
