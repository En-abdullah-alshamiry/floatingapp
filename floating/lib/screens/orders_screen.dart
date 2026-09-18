import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';

String _price(double amount, AppLocalizations l10n) =>
    '${amount.toStringAsFixed(2)} ${l10n.tr('currency')}';

const Set<String> _activeStatuses = {
  'processing',
  'confirmed',
  'shipped',
};

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'processing':
      return AppColors.lightWarning;
    case 'confirmed':
      return Colors.blue.shade600;
    case 'shipped':
      return Colors.purple;
    case 'delivered':
      return AppColors.lightSuccess;
    case 'cancelled':
      return AppColors.lightError;
    default:
      return AppColors.lightGoldDark;
  }
}

String _statusLabel(
    String status,
    bool isRTL,
    ) {
  switch (status.toLowerCase()) {
    case 'processing':
      return isRTL ? 'قيد المعالجة' : 'Processing';
    case 'confirmed':
      return isRTL ? 'مؤكد' : 'Confirmed';
    case 'shipped':
      return isRTL ? 'تم الشحن' : 'Shipped';
    case 'delivered':
      return isRTL ? 'تم التوصيل' : 'Delivered';
    case 'cancelled':
      return isRTL ? 'ملغي' : 'Cancelled';
    default:
      return status;
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortOrders(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
      ) {
    final sorted = List<
        QueryDocumentSnapshot<Map<String, dynamic>>>.from(
      orders,
    );

    sorted.sort((a, b) {
      final aDate = _getDate(a.data()['date']);
      final bDate = _getDate(b.data()['date']);

      return bDate.compareTo(aDate);
    });

    return sorted;
  }

  DateTime _getDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider =
    Provider.of<LocaleProvider>(context);
    final isRTL = localeProvider.isRTL;
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Directionality(
        textDirection:
        isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.tr('orders_title')),
          ),
          body: _buildLoginRequired(
            context,
            isRTL,
            l10n,
            cs,
          ),
        ),
      );
    }

    return Directionality(
      textDirection:
      isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.tr('orders_title')),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: l10n.tr('active_orders'),
                ),
                Tab(
                  text: l10n.tr('previous_orders'),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _ordersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(
                    context,
                    isRTL,
                    l10n,
                    cs,
                  );
                }

                final documents =
                _sortOrders(snapshot.data?.docs ?? []);

                final active = documents.where((doc) {
                  final status =
                  (doc.data()['status'] ?? '')
                      .toString()
                      .toLowerCase();

                  return _activeStatuses.contains(status);
                }).toList();

                final previous = documents.where((doc) {
                  final status =
                  (doc.data()['status'] ?? '')
                      .toString()
                      .toLowerCase();

                  return !_activeStatuses.contains(status);
                }).toList();

                return TabBarView(
                  children: [
                    _buildOrdersList(
                      context,
                      active,
                      isRTL,
                      l10n,
                      cs,
                    ),
                    _buildOrdersList(
                      context,
                      previous,
                      isRTL,
                      l10n,
                      cs,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.darkGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.6),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.tr('orders_empty'),
                style: isRTL
                    ? GoogleFonts.notoSansArabic(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                )
                    : GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tr('orders_empty_desc'),
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                      AppRoutes.home,
                          (route) => false,
                    ),
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                ),
                label: Text(
                  l10n.tr('continue_shopping'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView.builder(
          padding:
          const EdgeInsets.symmetric(vertical: 8),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];

            return _OrderCard(
              order: order.data(),
              isRTL: isRTL,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.orderDetails,
                  arguments: order.id,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginRequired(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColors.gold,
            ),
            const SizedBox(height: 20),
            Text(
              isRTL
                  ? 'يجب تسجيل الدخول لعرض طلباتك'
                  : 'Please login to view your orders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'رجوع' : 'Back',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      bool isRTL,
      AppLocalizations l10n,
      ColorScheme cs,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.lightError,
            ),
            const SizedBox(height: 16),
            Text(
              isRTL
                  ? 'تعذر تحميل الطلبات'
                  : 'Unable to load orders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isRTL,
    required this.onTap,
  });

  final Map<String, dynamic> order;
  final bool isRTL;
  final VoidCallback onTap;

  DateTime _getDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }

  String _formatDate(dynamic value) {
    final date = _getDate(value);

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs =
        Theme.of(context).colorScheme;
    final l10n =
    AppLocalizations.of(context);

    final status =
    (order['status'] ?? 'processing')
        .toString();

    final statusColor =
    _statusColor(status);

    final statusLabel =
    _statusLabel(status, isRTL);

    final products =
        order['products'] as List<dynamic>? ?? [];

    final itemsPreview = products.map((item) {
      if (item is! Map) {
        return '';
      }

      final name = isRTL
          ? (item['nameAr'] ?? '')
          : (item['nameEn'] ?? '');

      final quantity =
          item['quantity'] ?? 1;

      return '$name ×$quantity';
    }).where((item) => item.isNotEmpty).join(' • ');

    final total =
        (order['total'] as num?)?.toDouble() ?? 0.0;

    final isCancellable =
        status == 'processing' ||
            status == 'confirmed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        (order['id'] ??
                            '')
                            .toString(),
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
                        _formatDate(
                          order['date'],
                        ),
                        style: TextStyle(
                          color:
                          cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    color: statusColor
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                    border: Border.all(
                      color: statusColor
                          .withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              itemsPreview.isEmpty
                  ? (isRTL
                  ? 'لا توجد منتجات'
                  : 'No products')
                  : itemsPreview,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color:
                cs.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: cs.outlineVariant,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.tr('total_label'),
                  style: TextStyle(
                    color:
                    cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _price(total, l10n),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight:
                    FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (isCancellable) ...[
              const SizedBox(height: 12),
              Align(
                alignment: isRTL
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child:
                OutlinedButton.icon(
                  onPressed: () =>
                      _cancelOrder(
                        context,
                        l10n,
                      ),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 18,
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                    AppColors.lightError,
                    side: BorderSide(
                      color: AppColors
                          .lightError
                          .withValues(
                        alpha: 0.4,
                      ),
                    ),
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  label: Text(
                    l10n.tr('cancel_order'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cancelOrder(
      BuildContext context,
      AppLocalizations l10n,
      ) async {
    final orderId =
    (order['id'] ?? '').toString();

    if (orderId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'cancelled',
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? 'تم إلغاء الطلب'
                : 'Order cancelled',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Error cancelling order: $e',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? 'تعذر إلغاء الطلب'
                : 'Unable to cancel order',
          ),
        ),
      );
    }
  }
}