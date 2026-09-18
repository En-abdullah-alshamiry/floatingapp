import 'product.dart';

enum OrderStatus {
  processing,
  confirmed,
  shipped,
  delivered,
  cancelled;

  String get arName {
    switch (this) {
      case OrderStatus.processing:
        return 'قيد المعالجة';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  String get enName {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.processing:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class OrderItem {
  final Product product;
  final int quantity;
  final String selectedSize;
  final String selectedColor;
  final double subtotal;

  const OrderItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    required this.subtotal,
  });

  OrderItem copyWith({
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
    double? subtotal,
  }) {
    return OrderItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'subtotal': subtotal,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
      quantity: json['quantity'] as int? ?? 1,
      selectedSize: json['selectedSize'] as String? ?? '',
      selectedColor: json['selectedColor']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> products;
  final DateTime date;
  final OrderStatus status;
  final double total;
  final String shippingAddress;
  final String paymentMethod;

  const Order({
    required this.id,
    required this.products,
    required this.date,
    required this.status,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  int get totalItems {
    return products.fold(
      0,
          (sum, item) => sum + item.quantity,
    );
  }

  bool get isCancellable {
    return status == OrderStatus.processing ||
        status == OrderStatus.confirmed;
  }

  Order copyWith({
    String? id,
    List<OrderItem>? products,
    DateTime? date,
    OrderStatus? status,
    double? total,
    String? shippingAddress,
    String? paymentMethod,
  }) {
    return Order(
      id: id ?? this.id,
      products: products ?? this.products,
      date: date ?? this.date,
      status: status ?? this.status,
      total: total ?? this.total,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((item) => item.toJson()).toList(),
      'date': date.toIso8601String(),
      'status': status.name,
      'total': total,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)
          ?.map(
            (item) => OrderItem.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: OrderStatus.values.firstWhere(
            (status) => status.name == json['status'],
        orElse: () => OrderStatus.processing,
      ),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: json['shippingAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
    );
  }
}