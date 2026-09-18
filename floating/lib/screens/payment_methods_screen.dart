import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 1,
      'type': 'visa',
      'cardNumber': '•••• •••• •••• 4582',
      'cardHolder': 'SARA AHMED',
      'expiry': '09/28',
      'isDefault': true,
      'color': const Color(0xFF1A1F71),
      'brandColor': const Color(0xFF1A1F71),
    },
    {
      'id': 2,
      'type': 'mastercard',
      'cardNumber': '•••• •••• •••• 7193',
      'cardHolder': 'SARA AHMED',
      'expiry': '03/27',
      'isDefault': false,
      'color': const Color(0xFFEB001B),
      'brandColor': const Color(0xFFEB001B),
    },
    {
      'id': 3,
      'type': 'apple_pay',
      'cardNumber': 'Apple Pay',
      'cardHolder': 'sara@icloud.com',
      'expiry': '',
      'isDefault': false,
      'color': Colors.black,
      'brandColor': Colors.black,
    },
  ];

  void _deleteMethod(int id) {
    setState(() {
      _paymentMethods.removeWhere((m) => m['id'] == id);
    });
  }

  void _setDefault(int id) {
    setState(() {
      for (var m in _paymentMethods) {
        m['isDefault'] = m['id'] == id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            loc.tr('payment_title'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.gold),
              onPressed: () {},
            ),
          ],
        ),
        body: _paymentMethods.isEmpty
            ? _buildEmptyState(context, loc)
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _paymentMethods.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildPaymentCard(context, _paymentMethods[index], loc);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: AppColors.gold),
                        label: Text(
                          loc.tr('add_payment'),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> method, AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDefault = method['isDefault'] as bool;
    final brandColor = method['brandColor'] as Color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: brandColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ],
            ),
            border: Border.all(
              color: isDefault
                  ? AppColors.gold.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isDefault ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildBrandIcon(method),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCardTypeName(method['type']),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method['cardNumber'],
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        loc.tr('default_address'),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              if (method['expiry'].isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تاريخ الانتهاء',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method['expiry'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!isDefault)
                      TextButton.icon(
                        onPressed: () => _setDefault(method['id']),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(
                          loc.tr('set_default'),
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.gold,
                        ),
                      ),
                    IconButton(
                      onPressed: () => _deleteMethod(method['id']),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandIcon(Map<String, dynamic> method) {
    final type = method['type'] as String;
    final color = method['brandColor'] as Color;

    return Container(
      width: 48,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: _getBrandWidget(type, color),
      ),
    );
  }

  Widget _getBrandWidget(String type, Color color) {
    switch (type) {
      case 'visa':
        return Text(
          'VISA',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1,
          ),
        );
      case 'mastercard':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
            Transform.translate(
              offset: const Offset(-5, 0),
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      case 'apple_pay':
        return Icon(Icons.apple, color: color, size: 22);
      default:
        return Icon(Icons.credit_card, color: color, size: 22);
    }
  }

  String _getCardTypeName(String type) {
    switch (type) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'apple_pay':
        return 'Apple Pay';
      default:
        return 'Card';
    }
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.15),
                    AppColors.gold.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_off_outlined,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد طرق دفع',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف طريقة دفع لتسهيل عمليات الشراء',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
