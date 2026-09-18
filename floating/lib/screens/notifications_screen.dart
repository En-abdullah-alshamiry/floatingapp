import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'type': 'order',
      'title': 'تم تأكيد طلبك',
      'titleEn': 'Order Confirmed',
      'description': 'تم تأكيد طلب رقم #12345 بنجاح',
      'descriptionEn': 'Your order #12345 has been confirmed',
      'time': 'منذ 5 دقائق',
      'timeEn': '5 min ago',
      'read': false,
      'icon': Icons.local_shipping_outlined,
      'color': Colors.blue,
    },
    {
      'id': 2,
      'type': 'offer',
      'title': 'عرض خاص لك!',
      'titleEn': 'Special Offer for You!',
      'description': 'خصم 30% على جميع الفساتن حتى نهاية الأسبوع',
      'descriptionEn': '30% off on all dresses until end of week',
      'time': 'منذ ساعة',
      'timeEn': '1 hour ago',
      'read': false,
      'icon': Icons.local_offer_outlined,
      'color': AppColors.gold,
    },
    {
      'id': 3,
      'type': 'order',
      'title': 'طلبك في الطريق',
      'titleEn': 'Your Order is On The Way',
      'description': 'طلب رقم #12340 تم شحنه عبر أرامكس',
      'descriptionEn': 'Order #12340 has been shipped via Aramex',
      'time': 'منذ 3 ساعات',
      'timeEn': '3 hours ago',
      'read': true,
      'icon': Icons.delivery_dining_outlined,
      'color': Colors.green,
    },
    {
      'id': 4,
      'type': 'discount',
      'title': 'كود خصم حصري',
      'titleEn': 'Exclusive Discount Code',
      'description': 'استخدم كود Fashion20 واحصل على خصم 20%',
      'descriptionEn': 'Use code Fashion20 for 20% discount',
      'time': 'منذ يوم',
      'timeEn': '1 day ago',
      'read': true,
      'icon': Icons.discount_outlined,
      'color': Colors.purple,
    },
    {
      'id': 5,
      'type': 'offer',
      'title': 'مجموعة جديدة وصلت!',
      'titleEn': 'New Collection Has Arrived!',
      'description': 'اكتشف أحدث صيحات الموضة لموسم الصيف',
      'descriptionEn': 'Discover the latest fashion trends for summer',
      'time': 'منذ يومين',
      'timeEn': '2 days ago',
      'read': true,
      'icon': Icons.dry_cleaning_outlined,
      'color': Colors.pink,
    },
    {
      'id': 6,
      'type': 'order',
      'title': 'تم توصيل طلبك',
      'titleEn': 'Your Order Has Been Delivered',
      'description': 'تم توصيل طلب رقم #12300 بنجاح. نتمنى أن يعجبك!',
      'descriptionEn': 'Order #12300 has been delivered successfully. We hope you love it!',
      'time': 'منذ 3 أيام',
      'timeEn': '3 days ago',
      'read': true,
      'icon': Icons.check_circle_outline,
      'color': Colors.teal,
    },
  ];

  bool _allRead = false;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
      _allRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final unreadCount = _notifications.where((n) => !n['read']).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            loc.tr('notifications_title'),
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
            if (!_allRead && unreadCount > 0)
              TextButton(
                onPressed: _markAllRead,
                child: Text(
                  loc.tr('mark_all_read'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: _notifications.isEmpty
            ? _buildEmptyState(context, loc)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildNotificationCard(context, _notifications[index]);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRead = notification['read'] as bool;
    final notificationColor = notification['color'] as Color;
    final icon = notification['icon'] as IconData;

    return Container(
      decoration: BoxDecoration(
        color: isRead
            ? colorScheme.surface
            : AppColors.gold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? colorScheme.outlineVariant.withValues(alpha: 0.3)
              : AppColors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: notificationColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: notificationColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['description'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['time'],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.tr('notifications_empty'),
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.tr('notifications_empty_desc'),
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
