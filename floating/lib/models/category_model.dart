import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String nameAr;
  final String icon;
  final String? parentId;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    this.parentId,
    this.isActive = true,
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'icon': icon,
      'parentId': parentId,
      'isActive': isActive,
    };
  }

  /// Create from Firestore document
  factory CategoryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return CategoryModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      nameAr: data['nameAr']?.toString() ?? '',
      icon: data['icon']?.toString() ?? '',
      parentId: data['parentId']?.toString(),
      isActive: data['isActive'] == true,
    );
  }

  /// Create from JSON/Map
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      isActive: json['isActive'] != false,
    );
  }

  /// Copy with method for updates
  CategoryModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? icon,
    String? parentId,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
    );
  }
}