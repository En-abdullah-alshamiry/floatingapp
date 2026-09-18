import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';

String _price(double amount, AppLocalizations l10n) =>
    '${amount.toStringAsFixed(2)} ${l10n.tr('currency')}';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _deliveryIndex = 0;
  bool _isPlacingOrder = false;
  bool _isLoadingAddress = true;

  String _userName = '';
  String _userPhone = '';
  String _shippingAddress = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoadingAddress = false;
      });

      return;
    }

    String name = user.displayName ?? '';
    String phone = user.phoneNumber ?? '';
    String address = '';

    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDocument.exists) {
        final data = userDocument.data();

        if (data != null) {
          name = data['name']?.toString().isNotEmpty == true
              ? data['name'].toString()
              : data['displayName']?.toString() ?? name;

          phone = data['phone']?.toString().isNotEmpty == true
              ? data['phone'].toString()
              : data['phoneNumber']?.toString() ?? phone;

          address = data['address']?.toString() ?? '';
        }
      }

      /*
       * نحاول الحصول على العنوان الافتراضي
       * من مجموعة addresses الخاصة بالمستخدم.
       */
      final addressesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      if (addressesSnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>>? defaultAddress;

        for (final document in addressesSnapshot.docs) {
          final data = document.data();

          final isDefault = data['isDefault'] == true ||
              data['isDefaultAddress'] == true;

          if (isDefault) {
            defaultAddress = document;
            break;
          }
        }

        defaultAddress ??= addressesSnapshot.docs.first;

        final addressData = defaultAddress.data();

        final parts = <String>[
          addressData['address']?.toString() ?? '',
          addressData['street']?.toString() ?? '',
          addressData['city']?.toString() ?? '',
          addressData['area']?.toString() ?? '',
        ].where((value) => value.trim().isNotEmpty).toList();

        if (parts.isNotEmpty) {
          address = parts.join('، ');
        }

        if (phone.isEmpty &&
            addressData['phone']?.toString().isNotEmpty == true) {
          phone = addressData['phone'].toString();
        }
      }
    } catch (e) {
      debugPrint('Error loading checkout user data: $e');
    }

    if (!mounted) return;

    setState(() {
      _userName = name;
      _userPhone = phone;
      _shippingAddress = address;
      _isLoadingAddress = false;
    });
  }

  double get _shippingFee {
    final cart = Provider.of<CartProvider>(
      context,
      listen: false,
    );

    if (_deliveryIndex == 1) {
      return cart.deliveryFee == 0 ? 0 : 15.0;
    }

    return cart.deliveryFee;
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    final cart = Provider.of<CartProvider>(
      context,
      listen: false,
    );

    final l10n = AppLocalizations.of(context);

    final localeProvider = Provider.of<LocaleProvider>(
      context,
      listen: false,
    );

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localeProvider.isRTL
                ? 'يجب تسجيل الدخول أولاً لإتمام الطلب'
                : 'Please login first to place the order',
          ),
        ),
      );

      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localeProvider.isRTL
                ? 'السلة فارغة'
                : 'Your cart is empty',
          ),
        ),
      );

      return;
    }

    if (_shippingAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localeProvider.isRTL
                ? 'يرجى إضافة عنوان الشحن أولاً'
                : 'Please add a shipping address first',
          ),
          action: SnackBarAction(
            label: localeProvider.isRTL
                ? 'العناوين'
                : 'Addresses',
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.addresses,
              );
            },
          ),
        ),
      );

      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final shipping = _shippingFee;
      final subtotal = cart.subtotal;
      final discount = cart.discountAmount;
      final total = subtotal - discount + shipping;

      final orderNumber =
          'ORD-${DateTime.now().millisecondsSinceEpoch % 1000000}';

      final deliveryDays = _deliveryIndex == 1 ? 2 : 5;

      final eta = DateTime.now().add(
        Duration(days: deliveryDays),
      );

      /*
       * نحفظ نسخة مستقلة من المنتجات الموجودة
       * في السلة داخل الطلب.
       *
       * نستخدم السعر الفعلي:
       * discountPrice ?? price
       */
      final orderItems = cart.items.map((item) {
        final itemPrice =
            item.product.discountPrice ?? item.product.price;

        return {
          'productId': item.product.id,
          'nameAr': item.product.nameAr,
          'nameEn': item.product.nameEn,
          'price': itemPrice,
          'originalPrice': item.product.price,
          'quantity': item.quantity,
          'selectedColor': item.selectedColor,
          'selectedSize': item.selectedSize,
          'subtotal': itemPrice * item.quantity,
        };
      }).toList();

      /*
       * حفظ الطلب في Firestore.
       *
       * Collection:
       * orders
       */
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderNumber)
          .set({
        'id': orderNumber,

        'userId': user.uid,
        'userEmail': user.email ?? '',
        'userName': _userName.isNotEmpty
            ? _userName
            : user.displayName ?? '',

        'userPhone': _userPhone,

        'products': orderItems,

        'subtotal': subtotal,
        'discount': discount,
        'shippingFee': shipping,
        'total': total,

        'shippingAddress': _shippingAddress,

        'paymentMethod': 'card',

        'deliveryType':
        _deliveryIndex == 1 ? 'express' : 'standard',

        'status': 'processing',

        'date': FieldValue.serverTimestamp(),

        'estimatedDelivery': Timestamp.fromDate(
          eta,
        ),

        'createdAt': FieldValue.serverTimestamp(),
      });

      /*
       * نفرغ السلة فقط بعد نجاح
       * حفظ الطلب في Firestore.
       */
      cart.clearCart();

      if (!mounted) return;

      setState(() {
        _isPlacingOrder = false;
      });

      final isRTL = localeProvider.isRTL;

      final etaLabel =
          '${eta.day}/${eta.month}/${eta.year}';

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: 1,
                      ),
                      duration:
                      const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (
                          context,
                          value,
                          child,
                          ) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.check_circle,
                        size: 88,
                        color: AppColors.gold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      l10n.tr('order_placed'),
                      textAlign: TextAlign.center,
                      style: isRTL
                          ? GoogleFonts.notoSansArabic(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface,
                      )
                          : GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.tr('order_confirmation'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          _DialogRow(
                            label:
                            l10n.tr('order_number'),
                            value: orderNumber,
                          ),

                          const SizedBox(height: 8),

                          _DialogRow(
                            label: l10n.tr(
                              'estimated_delivery',
                            ),
                            value: etaLabel,
                          ),

                          const SizedBox(height: 8),

                          _DialogRow(
                            label:
                            l10n.tr('total_label'),
                            value:
                            _price(total, l10n),
                            highlight: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _GoldButton(
                        label:
                        l10n.tr('track_order'),
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();

                          Navigator.of(context).pushNamed(
                            AppRoutes.orders,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 4),

                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          dialogContext,
                        ).pop();

                        Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                          AppRoutes.home,
                              (route) => false,
                        );
                      },
                      child: Text(
                        l10n.tr('continue_shopping'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint(
        'Error saving order: $e',
      );

      if (!mounted) return;

      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localeProvider.isRTL
                ? 'حدث خطأ أثناء حفظ الطلب'
                : 'An error occurred while saving the order',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider =
    Provider.of<LocaleProvider>(context);

    final cart =
    Provider.of<CartProvider>(context);

    final isRTL = localeProvider.isRTL;

    final l10n =
    AppLocalizations.of(context);

    final cs =
        Theme.of(context).colorScheme;

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    final shipping = _shippingFee;

    final total =
        cart.subtotal -
            cart.discountAmount +
            shipping;

    return Directionality(
      textDirection:
      isRTL
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.tr('checkout_title'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: isWide
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: [
                              _buildAddressCard(context, isRTL, l10n, cs),
                              _buildDeliverySection(context, isRTL, l10n, cs),
                              _buildPaymentCard(context, isRTL, l10n, cs),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: [
                              _buildSummarySection(context, cart, isRTL, l10n, cs, shipping),
                            ],
                          ),
                        ),
                      ],
                    )
                        : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildAddressCard(context, isRTL, l10n, cs),
                        _buildDeliverySection(context, isRTL, l10n, cs),
                        _buildPaymentCard(context, isRTL, l10n, cs),
                        _buildSummarySection(context, cart, isRTL, l10n, cs, shipping),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              _buildPlaceOrderBar(
                context,
                total,
                isRTL,
                l10n,
                cs,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return _card(
      cs,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            cs,
            l10n.tr('shipping_address'),
          ),

          const SizedBox(height: 12),

          if (_isLoadingAddress)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient:
                    AppColors.goldGradient,
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName.isNotEmpty
                            ? _userName
                            : (isRTL
                            ? 'المستخدم'
                            : 'User'),
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),

                      if (_userPhone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _userPhone,
                          style: TextStyle(
                            color:
                            cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 4),

                      Text(
                        _shippingAddress.isNotEmpty
                            ? _shippingAddress
                            : (isRTL
                            ? 'لم يتم إضافة عنوان'
                            : 'No address added'),
                        style: TextStyle(
                          color:
                          _shippingAddress
                              .isNotEmpty
                              ? cs
                              .onSurfaceVariant
                              : AppColors
                              .lightError,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () async {
                    await Navigator.of(context)
                        .pushNamed(
                      AppRoutes.addresses,
                    );

                    await _loadUserData();
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                  ),
                  color: AppColors.gold,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return _card(
      cs,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            cs,
            l10n.tr('delivery_method'),
          ),

          const SizedBox(height: 12),

          _DeliveryOption(
            selected: _deliveryIndex == 0,
            icon: Icons.local_shipping_outlined,
            title:
            l10n.tr('standard_delivery'),
            subtitle:
            l10n.tr('delivery_standard_desc'),
            onTap: () {
              setState(() {
                _deliveryIndex = 0;
              });
            },
            cs: cs,
          ),

          const SizedBox(height: 10),

          _DeliveryOption(
            selected: _deliveryIndex == 1,
            icon: Icons.bolt_outlined,
            title:
            l10n.tr('express_delivery'),
            subtitle:
            l10n.tr('delivery_express_desc'),
            onTap: () {
              setState(() {
                _deliveryIndex = 1;
              });
            },
            cs: cs,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return _card(
      cs,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            cs,
            l10n.tr('payment_method'),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gold.withValues(
                  alpha: 0.4,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius:
                    BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.outlineVariant,
                    ),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    size: 22,
                    color: AppColors.goldDark,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL
                            ? 'الدفع عند الاستلام'
                            : 'Cash on Delivery',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        isRTL
                            ? 'سيتم تأكيد الدفع عند استلام الطلب'
                            : 'Payment will be confirmed upon delivery',
                        style: TextStyle(
                          color:
                          cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.check_circle,
                  size: 22,
                  color:
                  AppColors.lightSuccess,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context,
      CartProvider cart,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      double shipping,
      ) {
    return _card(
      cs,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          _sectionTitle(
            cs,
            l10n.tr('order_summary'),
          ),

          const SizedBox(height: 12),

          for (final item in cart.items)
            Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${isRTL ? item.product.nameAr : item.product.nameEn} ×${item.quantity}',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface,
                      ),
                    ),
                  ),

                  Text(
                    _price(
                      (item.product.discountPrice ??
                          item.product.price) *
                          item.quantity,
                      l10n,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Divider(height: 1),
          ),

          _SummaryRow(
            label:
            l10n.tr('subtotal_label'),
            value:
            _price(cart.subtotal, l10n),
          ),

          if (cart.discountAmount > 0)
            _SummaryRow(
              label:
              l10n.tr('discount_label'),
              value:
              '-${_price(cart.discountAmount, l10n)}',
              valueColor:
              AppColors.lightSuccess,
            ),

          _SummaryRow(
            label:
            l10n.tr('shipping_label'),
            value: shipping == 0
                ? l10n.tr('free_shipping')
                : _price(shipping, l10n),
            valueColor: shipping == 0
                ? AppColors.lightSuccess
                : null,
          ),

          const Padding(
            padding:
            EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Divider(height: 1),
          ),

          _SummaryRow(
            label:
            l10n.tr('total_label'),
            value: _price(
              cart.subtotal -
                  cart.discountAmount +
                  shipping,
              l10n,
            ),
            bold: true,
            valueColor: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderBar(
      BuildContext context,
      double total,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(
              alpha: 0.4,
            ),
            blurRadius: 12,
            offset:
            const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: _GoldButton(
            label:
            '${l10n.tr('place_order')} • ${_price(total, l10n)}',
            onPressed:
            _isPlacingOrder
                ? null
                : _placeOrder,
          ),
        ),
      ),
    );
  }

  Widget _card(
      ColorScheme cs, {
        required Widget child,
      }) {
    return Container(
      margin:
      const EdgeInsets.fromLTRB(
        16,
        6,
        16,
        6,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(
              alpha: 0.4,
            ),
            blurRadius: 12,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
      ColorScheme cs,
      String text,
      ) {
    return Text(
      text,
      style: TextStyle(
        fontWeight:
        FontWeight.w700,
        fontSize: 16,
        color: cs.onSurface,
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  const _DeliveryOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.cs,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.gold.withValues(
        alpha: 0.10,
      )
          : cs.surfaceContainerLow,
      borderRadius:
      BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding:
          const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.gold.withValues(
                alpha: 0.7,
              )
                  : cs.outlineVariant,
              width:
              selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color: selected
                      ? AppColors.gold.withValues(
                    alpha: 0.18,
                  )
                      : cs
                      .surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? AppColors.goldDark
                      : cs.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w700,
                        fontSize: 14,
                        color:
                        cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                        cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                selected
                    ? Icons
                    .radio_button_checked
                    : Icons
                    .radio_button_unchecked,
                size: 22,
                color: selected
                    ? AppColors.gold
                    : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize:
              bold ? 16 : 14,
              fontWeight: bold
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: valueColor ??
                  Theme.of(context)
                      .colorScheme
                      .onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color:
              cs.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlight
                ? FontWeight.w800
                : FontWeight.w600,
            color: highlight
                ? AppColors.gold
                : cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled =
        onPressed == null;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : AppColors.goldGradient,
          color: disabled
              ? Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              : null,
          borderRadius:
          BorderRadius.circular(16),
          boxShadow: disabled
              ? null
              : [
            BoxShadow(
              color:
              AppColors.gold
                  .withValues(
                alpha: 0.35,
              ),
              blurRadius: 16,
              offset:
              const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: disabled
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            )
                : Text(
              label,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight:
                FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}