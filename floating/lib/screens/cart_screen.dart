import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';
import '../models/product.dart';

String _price(double amount, AppLocalizations l10n) =>
    '${amount.toStringAsFixed(2)} ${l10n.tr('currency')}';

IconData _categoryIcon(Category category) {
  switch (category) {
    case Category.men:
      return Icons.man_outlined;
    case Category.women:
      return Icons.woman_outlined;
    case Category.kids:
      return Icons.child_care_outlined;
    case Category.shoes:
      return Icons.snowshoeing;
    case Category.bags:
      return Icons.work_outline;
    case Category.accessories:
      return Icons.watch_outlined;
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController =
  TextEditingController();

  bool _couponApplied = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final cart =
    Provider.of<CartProvider>(context, listen: false);

    final code = _couponController.text.trim();

    if (code.isEmpty) return;

    FocusScope.of(context).unfocus();

    cart.applyDiscount(code);

    final applied = cart.discountAmount > 0;

    setState(() {
      _couponApplied = applied;
    });

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          applied
              ? l10n.tr('success_coupon')
              : l10n.tr('invalid_coupon'),
        ),
      ),
    );
  }

  void _continueShopping(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider =
    Provider.of<LocaleProvider>(context);

    final cart = Provider.of<CartProvider>(context);

    final isRTL = localeProvider.isRTL;
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection:
      isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${l10n.tr('cart_title')} (${cart.itemCount})',
          ),
        ),
        body: SafeArea(
          child: cart.isEmpty
              ? _buildEmpty(
            context,
            isRTL,
            l10n,
            cs,
          )
              : Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: width > 900
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) => _buildCartItem(
                        context,
                        cart,
                        index,
                        isRTL,
                        l10n,
                        cs,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildCouponCard(context, isRTL, l10n, cs),
                          _buildSummaryCard(context, cart, isRTL, l10n, cs),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: _GoldButton(
                                label: l10n.tr('checkout'),
                                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.checkout),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        for (var index = 0; index < cart.items.length; index++)
                          _buildCartItem(context, cart, index, isRTL, l10n, cs),
                        _buildCouponCard(context, isRTL, l10n, cs),
                        _buildSummaryCard(context, cart, isRTL, l10n, cs),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  _buildCheckoutBar(context, cart, isRTL, l10n, cs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context,
      CartProvider cart,
      int index,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    final item = cart.items[index];
    final product = item.product;

    final base =
    product.colors.isNotEmpty
        ? product.colors.first
        : cs.primary;

    final meta = [
      if (item.selectedColor != null)
        item.selectedColor!,
      if (item.selectedSize != null)
        item.selectedSize!,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        6,
        16,
        6,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildProductImage(
            product,
            base,
            cs,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        isRTL
                            ? product.nameAr
                            : product.nameEn,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w600,
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        cart.removeItem(index);

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.tr(
                                'removed_from_cart',
                              ),
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color:
                        cs.onSurfaceVariant,
                      ),
                      visualDensity:
                      VisualDensity.compact,
                    ),
                  ],
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    style: TextStyle(
                      color:
                      cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuantityStepper(
                      quantity: item.quantity,
                      onDecrement: () =>
                          cart.decrementQuantity(
                            index,
                          ),
                      onIncrement: () =>
                          cart.incrementQuantity(
                            index,
                          ),
                      cs: cs,
                    ),
                    const Spacer(),
                    Text(
                      _price(
                        item.price,
                        l10n,
                      ),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight:
                        FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(
      Product product,
      Color base,
      ColorScheme cs,
      ) {
    return Container(
      width: 72,
      height: 88,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.images.isNotEmpty
          ? Image.network(
        product.images.first,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return _buildImageFallback(
            product,
            base,
          );
        },
      )
          : _buildImageFallback(
        product,
        base,
      ),
    );
  }

  Widget _buildImageFallback(
      Product product,
      Color base,
      ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            base.withValues(alpha: 0.35),
            base.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        _categoryIcon(product.category),
        size: 32,
        color: base.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildCouponCard(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        6,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: AppColors.gold,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tr('apply_coupon'),
                style: TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                  _couponController,
                  textCapitalization:
                  TextCapitalization
                      .characters,
                  decoration: InputDecoration(
                    hintText:
                    l10n.tr(
                      'enter_coupon',
                    ),
                    isDense: true,
                    prefixIcon:
                    const Icon(
                      Icons.tag,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:
                    AppColors.goldGradient,
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    onTap: _applyCoupon,
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Text(
                        l10n.tr('apply'),
                        style: TextStyle(
                          color: isRTL
                              ? Colors.black87
                              : Colors.black,
                          fontWeight:
                          FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_couponApplied) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color:
                  AppColors.lightSuccess,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.tr('coupon_applied'),
                  style: const TextStyle(
                    color:
                    AppColors.lightSuccess,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context,
      CartProvider cart,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        6,
        16,
        6,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.tr('cart_summary'),
            style: TextStyle(
              fontWeight:
              FontWeight.w700,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label:
            l10n.tr('subtotal_label'),
            value:
            _price(cart.subtotal, l10n),
            valueColor:
            cs.onSurface,
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
            value: cart.deliveryFee == 0
                ? l10n.tr(
              'free_shipping',
            )
                : _price(
              cart.deliveryFee,
              l10n,
            ),
            valueColor:
            cart.deliveryFee == 0
                ? AppColors.lightSuccess
                : cs.onSurface,
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
            value:
            _price(cart.total, l10n),
            valueColor:
            AppColors.gold,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(
      BuildContext context,
      CartProvider cart,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
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
            color:
            cs.shadow.withValues(alpha: 0.4),
            blurRadius: 12,
            offset:
            const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  l10n.tr('total_label'),
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  _price(
                    cart.total,
                    l10n,
                  ),
                  style:
                  const TextStyle(
                    color: AppColors.gold,
                    fontWeight:
                    FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _GoldButton(
                label:
                l10n.tr('checkout'),
                onPressed: () =>
                    Navigator.of(
                      context,
                    ).pushNamed(
                      AppRoutes.checkout,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient:
                AppColors.darkGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow
                        .withValues(
                      alpha: 0.6,
                    ),
                    blurRadius: 16,
                    offset:
                    const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons
                    .shopping_cart_outlined,
                size: 40,
                color:
                AppColors.gold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.tr('cart_empty'),
              style: isRTL
                  ? GoogleFonts
                  .notoSansArabic(
                fontSize: 22,
                fontWeight:
                FontWeight.w700,
                color:
                cs.onSurface,
              )
                  : GoogleFonts
                  .playfairDisplay(
                fontSize: 22,
                fontWeight:
                FontWeight.w700,
                color:
                cs.onSurface,
              ),
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tr(
                'cart_empty_desc',
              ),
              style: TextStyle(
                color:
                cs.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () =>
                  _continueShopping(
                    context,
                  ),
              icon: const Icon(
                Icons
                    .shopping_bag_outlined,
              ),
              label: Text(
                l10n.tr(
                  'continue_shopping',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper
    extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.cs,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: cs.outlineVariant,
        ),
        borderRadius:
        BorderRadius.circular(12),
        color:
        cs.surfaceContainerLow,
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: onDecrement,
            color:
            cs.onSurfaceVariant,
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontWeight:
                FontWeight.w700,
                fontSize: 14,
                color:
                cs.onSurface,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: onIncrement,
            color:
            AppColors.goldDark,
          ),
        ],
      ),
    );
  }
}

class _StepButton
    extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow
    extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

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
                color: Theme.of(
                  context,
                )
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
              fontWeight:
              bold
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldButton
    extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient:
          AppColors.goldGradient,
          borderRadius:
          BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold
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
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight:
                FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}