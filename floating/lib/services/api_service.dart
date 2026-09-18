import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String _baseUrl = 'https://dummyjson.com';

  // ============================================================
  // جلب جميع المنتجات
  // ============================================================

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?limit=100'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      return [];
    }

    final productsJson = data['products'];

    if (productsJson is! List) {
      return [];
    }

    final list = productsJson
        .whereType<Map<String, dynamic>>()
        .map(_productFromApi)
        .toList();

    // دمج حقائب ومنتجات أطفال الموك لضمان ظهورها دائماً في القائمة العامة
    list.addAll(_getMockBags());
    list.addAll(_getMockKids());

    return list;
  }

  // ============================================================
  // جلب المنتجات المحلية (Fallback)
  // ============================================================

  List<Product> _getMockBags() {
    return [
      Product(
        id: 'bag-1',
        nameAr: 'حقيبة يد فاخرة',
        nameEn: 'Luxury Handbag',
        descriptionAr: 'حقيبة يد جلدية أنيقة تناسب جميع المناسبات.',
        descriptionEn: 'Elegant leather handbag suitable for all occasions.',
        price: 250.0,
        discountPrice: 199.0,
        images: ['https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=500&q=80'],
        category: Category.bags,
        rating: 4.8,
        reviewCount: 15,
        isNew: true,
      ),
      Product(
        id: 'bag-2',
        nameAr: 'حقيبة ظهر عصرية',
        nameEn: 'Modern Backpack',
        descriptionAr: 'حقيبة ظهر مريحة وواسعة للعمل أو الدراسة.',
        descriptionEn: 'Comfortable and spacious backpack for work or study.',
        price: 150.0,
        images: ['https://images.unsplash.com/photo-1553062407-98eeb94c6a62?auto=format&fit=crop&w=500&q=80'],
        category: Category.bags,
        rating: 4.5,
        reviewCount: 22,
      ),
      Product(
        id: 'bag-3',
        nameAr: 'حقيبة كتف كلاسيكية',
        nameEn: 'Classic Shoulder Bag',
        descriptionAr: 'تصميم كلاسيكي يجمع بين الأناقة والعملية.',
        descriptionEn: 'Classic design that combines elegance and practicality.',
        price: 180.0,
        discountPrice: 150.0,
        images: ['https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=500&q=80'],
        category: Category.bags,
        rating: 4.7,
        reviewCount: 10,
        isBestSeller: true,
      ),
      Product(
        id: 'bag-4',
        nameAr: 'حقيبة صغيرة للسهرات',
        nameEn: 'Evening Clutch',
        descriptionAr: 'حقيبة صغيرة وأنيقة للمناسبات الخاصة.',
        descriptionEn: 'Small and elegant clutch for special occasions.',
        price: 120.0,
        images: ['https://images.unsplash.com/photo-1566150905458-1bf1fd113f0d?auto=format&fit=crop&w=500&q=80'],
        category: Category.bags,
        rating: 4.6,
        reviewCount: 8,
      ),
    ];
  }

  List<Product> _getMockKids() {
    return [
      Product(
        id: 'kid-1',
        nameAr: 'طقم ولادي كاجوال عصري',
        nameEn: 'Modern Casual Boys Set',
        descriptionAr: 'طقم أنيق يجمع بين الراحة والموضة الحديثة للأطفال.',
        descriptionEn: 'Stylish set combining comfort and modern fashion for kids.',
        price: 125.0,
        discountPrice: 95.0,
        images: ['https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=500&q=80'],
        category: Category.kids,
        sizes: ['S', 'M', 'L', 'XL'],
        rating: 4.9,
        reviewCount: 42,
        isNew: true,
      ),
      Product(
        id: 'kid-2',
        nameAr: 'فستان بناتي مخملي فاخر',
        nameEn: 'Luxury Velvet Girls Dress',
        descriptionAr: 'فستان مخملي بتصميم عصري وألوان جذابة.',
        descriptionEn: 'Velvet dress with modern design and attractive colors.',
        price: 180.0,
        images: ['https://images.unsplash.com/photo-1621451537084-482c73073a0f?auto=format&fit=crop&w=500&q=80'],
        category: Category.kids,
        sizes: ['S', 'M', 'L', 'XL'],
        rating: 4.8,
        reviewCount: 35,
      ),
      Product(
        id: 'kid-3',
        nameAr: 'هودي للأطفال ستايل ستريت وير',
        nameEn: 'Kids Streetwear Hoodie',
        descriptionAr: 'هودي عصري بتصميم مريح وألوان تريندي.',
        descriptionEn: 'Modern hoodie with comfortable design and trendy colors.',
        price: 145.0,
        discountPrice: 110.0,
        images: ['https://images.unsplash.com/photo-1522771930-78848d9293e8?auto=format&fit=crop&w=500&q=80'],
        category: Category.kids,
        sizes: ['S', 'M', 'L', 'XL'],
        rating: 4.7,
        reviewCount: 28,
        isBestSeller: true,
      ),
      Product(
        id: 'kid-4',
        nameAr: 'حذاء نايكي رياضي للأطفال',
        nameEn: 'Kids Nike Sport Shoes',
        descriptionAr: 'حذاء رياضي متطور يوفر الراحة والأداء العالي.',
        descriptionEn: 'Advanced sports shoe providing comfort and high performance.',
        price: 220.0,
        images: ['https://images.unsplash.com/photo-1514989940723-e8e51635b782?auto=format&fit=crop&w=500&q=80'],
        category: Category.kids,
        sizes: ['28', '30', '32', '34'],
        rating: 4.9,
        reviewCount: 65,
      ),
      Product(
        id: 'kid-5',
        nameAr: 'بدلة أطفال رسمية عصرية',
        nameEn: 'Modern Formal Kids Suit',
        descriptionAr: 'بدلة أنيقة للمناسبات الخاصة بلمسة عصرية.',
        descriptionEn: 'Elegant suit for special occasions with a modern touch.',
        price: 350.0,
        discountPrice: 280.0,
        images: ['https://images.unsplash.com/photo-1503919919749-6466a55d6928?auto=format&fit=crop&w=500&q=80'],
        category: Category.kids,
        sizes: ['S', 'M', 'L', 'XL'],
        rating: 5.0,
        reviewCount: 15,
        isNew: true,
      ),
    ];
  }

  // ============================================================
  // جلب المنتجات حسب التصنيف
  // ============================================================

  Future<List<Product>> getProductsByCategory(
      String category,
      ) async {
    final encodedCategory = Uri.encodeComponent(
      category.trim(),
    );

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/products/category/$encodedCategory',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load category products: '
            '${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      return [];
    }

    final productsJson = data['products'];

    if (productsJson is! List) {
      return [];
    }

    final products = productsJson
        .whereType<Map<String, dynamic>>()
        .map(_productFromApi)
        .toList();

    // إذا كان القسم فارغاً من الـ API، نضيف منتجات تجريبية
    if (category.toLowerCase() == 'bags' && products.isEmpty) {
      return _getMockBags();
    }
    if (category.toLowerCase() == 'kids' && products.isEmpty) {
      return _getMockKids();
    }

    return products;
  }

  // ============================================================
  // البحث عن المنتجات
  // ============================================================

  Future<List<Product>> searchProducts(
      String query,
      ) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return getProducts();
    }

    final encodedQuery = Uri.encodeQueryComponent(
      cleanQuery,
    );

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/products/search?q=$encodedQuery',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to search products: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      return [];
    }

    final productsJson = data['products'];

    if (productsJson is! List) {
      return [];
    }

    final list = productsJson
        .whereType<Map<String, dynamic>>()
        .map(_productFromApi)
        .toList();

    // دمج المنتجات المحلية لضمان ظهورها دائماً
    list.addAll(_getMockBags());
    list.addAll(_getMockKids());

    return list;
  }

  // ============================================================
  // جلب منتج واحد
  // ============================================================

  Future<Product> getProductById(
      int id,
      ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load product: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid product response');
    }

    return _productFromApi(data);
  }

  // ============================================================
  // تحويل بيانات DummyJSON إلى Product Model
  // ============================================================

  Product _productFromApi(
      Map<String, dynamic> json,
      ) {
    final title = json['title']?.toString() ?? 'Product';

    final description =
        json['description']?.toString() ?? '';

    final categoryValue =
        json['category']?.toString() ?? '';

    final price =
        (json['price'] as num?)?.toDouble() ?? 0.0;

    final discountPercentage =
        (json['discountPercentage'] as num?)
            ?.toDouble() ??
            0.0;

    final rating =
        (json['rating'] as num?)?.toDouble() ?? 0.0;

    final stock =
        (json['stock'] as num?)?.toInt() ?? 0;

    final thumbnail =
        json['thumbnail']?.toString() ?? '';

    // ------------------------------------------------------------
    // الصور
    // ------------------------------------------------------------

    final List<String> images = [];

    final rawImages = json['images'];

    if (rawImages is List) {
      for (final image in rawImages) {
        final imageUrl = image.toString();

        if (imageUrl.isNotEmpty) {
          images.add(imageUrl);
        }
      }
    }

    if (images.isEmpty && thumbnail.isNotEmpty) {
      images.add(thumbnail);
    }

    // ------------------------------------------------------------
    // حساب السعر بعد الخصم
    // ------------------------------------------------------------

    double? discountPrice;

    if (discountPercentage > 0 &&
        price > 0 &&
        discountPercentage < 100) {
      discountPrice =
          price * (1 - discountPercentage / 100);
    }

    // ------------------------------------------------------------
    // التصنيف
    // ------------------------------------------------------------

    final category = _mapCategory(categoryValue, title, description);

    return Product(
      id: json['id']?.toString() ?? '',
      nameAr: title,
      nameEn: title,
      descriptionAr: description,
      descriptionEn: description,
      price: price,
      discountPrice: discountPrice,
      images: images,
      category: category,
      colors: const [],
      sizes: const [],
      rating: rating,
      reviewCount: (json['reviews'] as List?)?.length ?? 0,
      isNew: rating > 4.8 || stock < 10,
      isBestSeller: rating >= 4.5,
      isFavorite: false,
      available: stock > 0,
    );
  }

  // ============================================================
  // تحويل تصنيفات API إلى تصنيفات التطبيق
  // ============================================================

  Category _mapCategory(
      String category,
      String title,
      String description,
      ) {
    final value = '$category $title $description'.toLowerCase().trim();

    // ترتيب التحقق مهم: النوع المحدد أولاً
    if (value.contains('shoe') || value.contains('footwear') || value.contains('sneaker')) {
      return Category.shoes;
    }

    if (value.contains('bag') || 
        value.contains('handbag') || 
        value.contains('backpack') || 
        value.contains('clutch') ||
        value.contains('pouch') ||
        value.contains('purse') ||
        value.contains('luggage') ||
        value.contains('tote')) {
      return Category.bags;
    }

    if (value.contains('watch') ||
        value.contains('jewel') ||
        value.contains('ring') ||
        value.contains('necklace') ||
        value.contains('earring') ||
        value.contains('sunglass') ||
        value.contains('accessory') ||
        value.contains('belt')) {
      return Category.accessories;
    }

    if (value.contains('kid') ||
        value.contains('child') ||
        value.contains('baby') ||
        value.contains('junior') ||
        value.contains('toddler')) {
      return Category.kids;
    }

    // ثم النوع العام
    if (value.contains('women') ||
        value.contains('dress') ||
        value.contains('skirt') ||
        value.contains('tops') ||
        value.contains('blouse')) {
      return Category.women;
    }

    if (value.contains('men') ||
        value.contains('shirt') ||
        value.contains('suit') ||
        value.contains('pants')) {
      return Category.men;
    }

    if (value.contains('boy') || value.contains('girl')) {
      return Category.kids;
    }

    // القيمة الافتراضية إذا لم يتطابق شيء
    return Category.women;
  }
}