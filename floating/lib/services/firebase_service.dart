import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();

  FirebaseService._internal();

  factory FirebaseService() => _instance;

  /// Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== Search Products ====================

  /// Search products by Arabic or English name
  Stream<List<ProductModel>> searchProducts(String query) {
    final searchQuery = query.trim().toLowerCase();

    if (searchQuery.isEmpty) {
      return getProductsStream();
    }

    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) {
        final nameEn = product.name.toLowerCase();
        final nameAr = product.nameAr.toLowerCase();

        return nameEn.contains(searchQuery) ||
            nameAr.contains(searchQuery);
      }).toList();
    });
  }

  // ==================== Get Products ====================

  /// Get all products from Firestore
  Stream<List<ProductModel>> getProductsStream() {
    return _db.collection('products').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList(),
    );
  }

  // ==================== Get Product By ID ====================

  /// Get one product by Firestore document ID
  Future<ProductModel?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return ProductModel.fromFirestore(doc);
  }
}