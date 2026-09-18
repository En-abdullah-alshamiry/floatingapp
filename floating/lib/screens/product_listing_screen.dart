import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

class ProductListingScreen extends StatefulWidget {
final String? category;
final String? categoryName;

const ProductListingScreen({
super.key,
this.category,
this.categoryName,
});

@override
State<ProductListingScreen> createState() =>
_ProductListingScreenState();
}

class _ProductListingScreenState
extends State<ProductListingScreen> {
  final ApiService _apiService = ApiService.instance;

  List<Product> _products = [];

  bool _isLoading = true;

  String? _error;

  String _selectedCategory = 'all';

  String _selectedSort = 'default';

  @override
  void initState() {
    super.initState();

    if (widget.category != null &&
        widget.category!.trim().isNotEmpty) {
      _selectedCategory =
          widget.category!.trim().toLowerCase();
    }

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
/*
       * نجلب المنتجات من الـ API.
       *
       * نستخدم getProducts() لجميع التصنيفات،
       * ثم نطبق التصنيف محليًا باستخدام Category
       * الموجود داخل Product.
       *
       * هذا يجعل التصنيفات:
       * men / women / kids / shoes / bags / accessories
       * متوافقة مع Model الخاص بالتطبيق.
       */
      final products =
      await _apiService.getProducts();

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

  List<Product> get _filtered {
    List<Product> list =
    List<Product>.from(_products);

/*
     * فلترة التصنيف.
     */
    if (_selectedCategory != 'all') {
      switch (_selectedCategory.toLowerCase()) {
        case 'men':
          list.removeWhere(
                (product) =>
            product.category != Category.men,
          );
          break;

        case 'women':
          list.removeWhere(
                (product) =>
            product.category != Category.women,
          );
          break;

        case 'kids':
          list.removeWhere(
                (product) =>
            product.category != Category.kids,
          );
          break;

        case 'shoes':
          list.removeWhere(
                (product) =>
            product.category != Category.shoes,
          );
          break;

        case 'bags':
          list.removeWhere(
                (product) =>
            product.category != Category.bags,
          );
          break;

        case 'accessories':
          list.removeWhere(
                (product) =>
            product.category !=
                Category.accessories,
          );
          break;
      }
    }

/*
     * ترتيب المنتجات.
     */
    switch (_selectedSort) {
      case 'price_low':
        list.sort(
              (a, b) =>
              (a.discountPrice ?? a.price)
                  .compareTo(
                b.discountPrice ?? b.price,
              ),
        );
        break;

      case 'price_high':
        list.sort(
              (a, b) =>
              (b.discountPrice ?? b.price)
                  .compareTo(
                a.discountPrice ?? a.price,
              ),
        );
        break;

      case 'rating':
        list.sort(
              (a, b) =>
              b.rating.compareTo(a.rating),
        );
        break;

      case 'newest':
        list.sort(
              (a, b) {
            if (a.isNew == b.isNew) {
              return 0;
            }

            return a.isNew ? -1 : 1;
          },
        );
        break;

      default:
        break;
    }

    return list;
  }

  String _categoryName(Category category) {
    return category.arName;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      Theme
          .of(context)
          .scaffoldBackgroundColor,
      shape:
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context,
              setModalState,) {
            return Padding(
              padding:
              const EdgeInsets.all(20),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.grey.shade400,
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'التصنيف',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label:
                        const Text('الكل'),
                        selected:
                        _selectedCategory ==
                            'all',
                        onSelected: (_) {
                          setModalState(() {
                            _selectedCategory =
                            'all';
                          });

                          setState(() {});
                        },
                      ),

                      ...Category.values.map(
                            (category) {
                          return ChoiceChip(
                            label: Text(
                              _categoryName(
                                category,
                              ),
                            ),
                            selected:
                            _selectedCategory ==
                                category.name,
                            onSelected: (_) {
                              setModalState(() {
                                _selectedCategory =
                                    category.name;
                              });

                              setState(() {});
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'ترتيب حسب',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _sortOption(
                    title: 'الافتراضي',
                    value: 'default',
                    setModalState:
                    setModalState,
                  ),

                  _sortOption(
                    title:
                    'السعر: من الأقل للأعلى',
                    value: 'price_low',
                    setModalState:
                    setModalState,
                  ),

                  _sortOption(
                    title:
                    'السعر: من الأعلى للأقل',
                    value: 'price_high',
                    setModalState:
                    setModalState,
                  ),

                  _sortOption(
                    title: 'الأعلى تقييمًا',
                    value: 'rating',
                    setModalState:
                    setModalState,
                  ),

                  _sortOption(
                    title: 'الأحدث',
                    value: 'newest',
                    setModalState:
                    setModalState,
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child:
                      const Text('تطبيق'),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sortOption({
    required String title,
    required String value,
    required StateSetter setModalState,
  }) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      groupValue: _selectedSort,
      onChanged: (newValue) {
        if (newValue == null) {
          return;
        }

        setModalState(() {
          _selectedSort = newValue;
        });

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filtered;

    final screenTitle =
        widget.categoryName ??
            widget.category ??
            'المنتجات';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          screenTitle.isNotEmpty
              ? screenTitle
              : 'المنتجات',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed:
            _showFilterBottomSheet,
            icon:
            const Icon(Icons.tune),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _buildBody(products),
      ),
    );
  }

  Widget _buildBody(List<Product> products,) {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery
                .of(context)
                .size
                .height *
                0.35,
          ),

          Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 60,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'تعذر تحميل المنتجات',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'تأكد من اتصال الإنترنت ثم حاول مرة أخرى.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed:
                    _loadProducts,
                    child:
                    const Text(
                      'إعادة المحاولة',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (products.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery
                .of(context)
                .size
                .height *
                0.35,
          ),

          const Center(
            child: Column(
              children: [
                Icon(
                  Icons
                      .shopping_bag_outlined,
                  size: 70,
                ),

                SizedBox(height: 16),

                Text(
                  'لا توجد منتجات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    double childAspectRatio = 0.54;

    if (screenWidth >= 1200) {
      crossAxisCount = 5;
      childAspectRatio = 0.62;
    } else if (screenWidth >= 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.60;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.58;
    } else if (screenWidth < 360) {
      childAspectRatio = 0.48;
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product-details',
              arguments: product,
            );
          },
        );
      },
    );
  }
}