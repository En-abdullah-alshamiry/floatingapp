import 'package:flutter/cupertino.dart';

enum PaymentType {
  visa,
  mastercard,
  amex,
  applePay,
  cashOnDelivery;

  String get arName {
    switch (this) {
      case PaymentType.visa:
        return 'فيزا';
      case PaymentType.mastercard:
        return 'ماستركارد';
      case PaymentType.amex:
        return 'أمريكان إكسبريس';
      case PaymentType.applePay:
        return 'أبل باي';
      case PaymentType.cashOnDelivery:
        return 'الدفع عند الاستلام';
    }
  }

  String get icon {
    switch (this) {
      case PaymentType.visa:
        return '💳';
      case PaymentType.mastercard:
        return '💳';
      case PaymentType.amex:
        return '💳';
      case PaymentType.applePay:
        return '🍎';
      case PaymentType.cashOnDelivery:
        return '💵';
    }
  }
}

class Address {
  final String id;
  final String title;
  final String street;
  final String city;
  final String country;
  final bool isDefault;

  const Address({
    required this.id,
    required this.title,
    required this.street,
    required this.city,
    required this.country,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? title,
    String? street,
    String? city,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get fullAddress => '$street, $city, $country';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'street': street,
      'city': city,
      'country': country,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String last4Digits;
  final String expiry;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.last4Digits,
    required this.expiry,
    this.isDefault = false,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentType? type,
    String? last4Digits,
    String? expiry,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      last4Digits: last4Digits ?? this.last4Digits,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get displayName => '${type.arName} ****$last4Digits';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'last4Digits': last4Digits,
      'expiry': expiry,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      type: PaymentType.values.firstWhere(
            (type) => type.name == json['type']?.toString(),
        orElse: () => PaymentType.visa,
      ),
      last4Digits: json['last4Digits']?.toString() ?? '',
      expiry: json['expiry']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  String get initials {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return '';
    }

    final parts = trimmedName.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts[0].characters.first}${parts[1].characters.first}'
        .toUpperCase();
  }

  Address? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) {
        return address;
      }
    }
    return null;
  }

  PaymentMethod? get defaultPaymentMethod {
    for (final payment in paymentMethods) {
      if (payment.isDefault) {
        return payment;
      }
    }
    return null;
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'paymentMethods':
      paymentMethods.map((payment) => payment.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      addresses: (json['addresses'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map(Address.fromJson)
          .toList() ??
          [],
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map(PaymentMethod.fromJson)
          .toList() ??
          [],
    );
  }
}