import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String? selectedColor;
  final String? selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  });

  double get price =>
      (product.discountPrice ?? product.price) * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  double _discountPercent = 0;
  final double _deliveryFee = 5.0;

  late Box _cartBox;

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  double get subtotal => _items.fold(
    0,
        (sum, item) => sum + item.price,
  );

  double get discountAmount =>
      subtotal * _discountPercent;

  double get deliveryFee =>
      subtotal > 100 ? 0 : _deliveryFee;

  double get total =>
      subtotal - discountAmount + deliveryFee;

  CartProvider() {
    _loadCart();
  }

  /// تحميل السلة من Hive
  Future<void> _loadCart() async {
    _cartBox = Hive.box('cart_box');

    _items.clear();

    for (final value in _cartBox.values) {
      if (value is! Map) continue;

      final rawProduct = value['product'];

      if (rawProduct is! Map) continue;

      try {
        final productMap =
        Map<String, dynamic>.from(rawProduct);

        final product =
        Product.fromJson(productMap);

        final quantity = value['quantity'] is int
            ? value['quantity'] as int
            : 1;

        final selectedColor =
        value['selectedColor']?.toString();

        final selectedSize =
        value['selectedSize']?.toString();

        _items.add(
          CartItem(
            product: product,
            quantity: quantity > 0 ? quantity : 1,
            selectedColor: selectedColor,
            selectedSize: selectedSize,
          ),
        );
      } catch (_) {
        // تجاهل أي عنصر قديم أو بيانات غير صالحة
        continue;
      }
    }

    notifyListeners();
  }

  /// حفظ السلة في Hive
  Future<void> _saveCart() async {
    await _cartBox.clear();

    for (final item in _items) {
      await _cartBox.add(item.toMap());
    }
  }

  /// إضافة منتج إلى السلة
  void addItem(
      Product product, {
        String? color,
        String? size,
        int qty = 1,
      }) {
    if (qty <= 0) return;

    final existing = _items.indexWhere(
          (item) =>
      item.product.id == product.id &&
          item.selectedColor == color &&
          item.selectedSize == size,
    );

    if (existing != -1) {
      _items[existing].quantity += qty;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: qty,
          selectedColor: color,
          selectedSize: size,
        ),
      );
    }

    _saveCart();
    notifyListeners();
  }

  /// حذف عنصر حسب الفهرس
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);

      _saveCart();
      notifyListeners();
    }
  }

  /// حذف جميع العناصر الخاصة بمنتج معين
  void removeByProductId(String productId) {
    _items.removeWhere(
          (item) => item.product.id == productId,
    );

    _saveCart();
    notifyListeners();
  }

  /// تحديث كمية منتج
  void updateQuantity(
      int index,
      int newQty,
      ) {
    if (index >= 0 &&
        index < _items.length &&
        newQty > 0) {
      _items[index].quantity = newQty;

      _saveCart();
      notifyListeners();
    } else if (newQty <= 0) {
      removeItem(index);
    }
  }

  /// زيادة الكمية
  void incrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity++;

      _saveCart();
      notifyListeners();
    }
  }

  /// تقليل الكمية
  void decrementQuantity(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      _saveCart();
      notifyListeners();
    }
  }

  /// تطبيق كود الخصم
  void applyDiscount(String code) {
    if (code.toUpperCase() == 'FASHION20') {
      _discountPercent = 0.2;
    } else if (code.toUpperCase() == 'NEWUSER') {
      _discountPercent = 0.15;
    } else {
      _discountPercent = 0;
    }

    notifyListeners();
  }

  /// إلغاء الخصم
  void clearDiscount() {
    _discountPercent = 0;
    notifyListeners();
  }

  /// تفريغ السلة
  void clearCart() {
    _items.clear();
    _discountPercent = 0;

    _saveCart();
    notifyListeners();
  }

  /// التحقق هل المنتج موجود في السلة
  bool isInCart(String productId) {
    return _items.any(
          (item) => item.product.id == productId,
    );
  }
}