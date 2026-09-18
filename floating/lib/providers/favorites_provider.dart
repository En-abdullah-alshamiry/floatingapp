import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  final Map<String, Product> _favorites = {};

  // للتوافق مع الشاشات القديمة التي تحفظ ID فقط
  final Set<String> _legacyFavoriteIds = {};

  late Box _favoritesBox;

  // المنتجات الجديدة
  List<Product> get favorites =>
      List.unmodifiable(_favorites.values);

  // جميع IDs سواء كانت من Product أو من النظام القديم
  List<String> get favoriteIds {
    final ids = <String>{
      ..._favorites.keys,
      ..._legacyFavoriteIds,
    };

    return List.unmodifiable(ids);
  }

  int get count => favoriteIds.length;

  bool get isEmpty => count == 0;

  FavoritesProvider() {
    _loadFavorites();
  }

  bool isFavorite(String productId) {
    return _favorites.containsKey(productId) ||
        _legacyFavoriteIds.contains(productId);
  }

  Product? getFavorite(String productId) {
    return _favorites[productId];
  }

  Future<void> _loadFavorites() async {
    _favoritesBox = Hive.box('favorites_box');

    _favorites.clear();
    _legacyFavoriteIds.clear();

    for (final value in _favoritesBox.values) {
      // البيانات الجديدة: Product كامل
      if (value is Map) {
        try {
          final productMap =
          Map<String, dynamic>.from(value);

          final product =
          Product.fromJson(productMap);

          if (product.id.isNotEmpty) {
            _favorites[product.id] = product;
          }
        } catch (_) {
          continue;
        }
      }

      // البيانات القديمة: ID فقط
      else if (value is String) {
        if (value.isNotEmpty) {
          _legacyFavoriteIds.add(value);
        }
      }
    }

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    await _favoritesBox.clear();

    // حفظ المنتجات الجديدة كاملة
    for (final product in _favorites.values) {
      await _favoritesBox.add(product.toJson());
    }

    // حفظ IDs القديمة التي لا يوجد لها Product كامل
    for (final id in _legacyFavoriteIds) {
      if (!_favorites.containsKey(id)) {
        await _favoritesBox.add(id);
      }
    }
  }

  // يقبل:
  // Product الجديد
  // أو String ID من الشاشات القديمة
  void toggleFavorite(dynamic value) {
    if (value is Product) {
      final productId = value.id;

      if (isFavorite(productId)) {
        _favorites.remove(productId);
        _legacyFavoriteIds.remove(productId);
      } else {
        _favorites[productId] = value;
      }

      _saveFavorites();
      notifyListeners();
      return;
    }

    if (value is String) {
      final productId = value;

      if (isFavorite(productId)) {
        _favorites.remove(productId);
        _legacyFavoriteIds.remove(productId);
      } else {
        _legacyFavoriteIds.add(productId);
      }

      _saveFavorites();
      notifyListeners();
    }
  }

  // يقبل Product أو ID
  void addFavorite(dynamic value) {
    if (value is Product) {
      _favorites[value.id] = value;
      _legacyFavoriteIds.remove(value.id);

      _saveFavorites();
      notifyListeners();
      return;
    }

    if (value is String) {
      if (value.isNotEmpty) {
        _legacyFavoriteIds.add(value);

        _saveFavorites();
        notifyListeners();
      }
    }
  }

  void removeFavorite(String productId) {
    _favorites.remove(productId);
    _legacyFavoriteIds.remove(productId);

    _saveFavorites();
    notifyListeners();
  }

  void clearFavorites() {
    _favorites.clear();
    _legacyFavoriteIds.clear();

    _saveFavorites();
    notifyListeners();
  }
}