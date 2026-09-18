import 'package:flutter/material.dart';

import '../models/product.dart';

import '../screens/about_screen.dart';
import '../screens/addresses_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../auth/login_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/orders_screen.dart';
import '../auth/otp_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/product_listing_screen.dart';
import '../screens/profile_screen.dart';
import '../auth/register_screen.dart';
import '../auth/reset_password_screen.dart';
import '../screens/search_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

// ==================== ROUTE CONSTANTS ====================

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword =
      '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword =
      '/reset-password';

  static const String home = '/home';
  static const String categories = '/categories';
  static const String categoryDetails =
      '/category-details';
  static const String productDetails =
      '/product-details';
  static const String search = '/search';

  static const String cart = '/cart';
  static const String checkout = '/checkout';

  static const String profile = '/profile';
  static const String wishlist = '/wishlist';

  static const String orders = '/orders';
  static const String orderDetails =
      '/order-details';

  static const String addresses = '/addresses';
  static const String settings = '/settings';
  static const String notifications =
      '/notifications';
  static const String editProfile =
      '/edit-profile';
  static const String paymentMethods =
      '/payment-methods';
  static const String about = '/about';

// ==================== ROUTE BUILDER ====================

  static Route<dynamic> generateRoute(RouteSettings routeSettings,) {
    switch (routeSettings.name) {
// ==================== SPLASH ====================

      case splash:
        return _buildRoute(
          const SplashScreen(),
          routeSettings,
        );

// ==================== ONBOARDING ====================

      case onboarding:
        return _buildRoute(
          const OnboardingScreen(),
          routeSettings,
        );

// ==================== AUTH ====================

      case login:
        return _buildRoute(
          const LoginScreen(),
          routeSettings,
        );

      case register:
        return _buildRoute(
          const RegisterScreen(),
          routeSettings,
        );

      case forgotPassword:
        return _buildRoute(
          const ForgotPasswordScreen(),
          routeSettings,
        );

      case otp:
        return _buildRoute(
          const OtpScreen(),
          routeSettings,
        );

      case resetPassword:
        return _buildRoute(
          const ResetPasswordScreen(),
          routeSettings,
        );

// ==================== HOME ====================

      case home:
        return _buildRoute(
          const HomeScreen(),
          routeSettings,
        );

// ==================== CATEGORIES ====================

      case categories:
        return _buildRoute(
          const CategoriesScreen(),
          routeSettings,
        );

      case categoryDetails:
        final args = routeSettings.arguments;

        if (args is Map) {
          final category =
          args['id']?.toString();

          final categoryName =
              args['nameAr']?.toString() ??
                  args['nameEn']?.toString();

          return _buildRoute(
            ProductListingScreen(
              category: category,
              categoryName: categoryName,
            ),
            routeSettings,
          );
        }

        return _buildRoute(
          const ProductListingScreen(),
          routeSettings,
        );

// ==================== PRODUCT DETAILS ====================

      case productDetails:
        final args = routeSettings.arguments;

        if (args is Product) {
          return _buildRoute(
            ProductDetailsScreen(
              product: args,
            ),
            routeSettings,
          );
        }

/*
         * إذا لم يتم تمرير Product حقيقي،
         * نرجع إلى Home بدل إنشاء منتج وهمي.
         */
        return _buildRoute(
          const HomeScreen(),
          routeSettings,
        );

// ==================== SEARCH ====================

      case search:
        return _buildRoute(
          const SearchScreen(),
          routeSettings,
        );

// ==================== CART ====================

      case cart:
        return _buildRoute(
          const CartScreen(),
          routeSettings,
        );

// ==================== CHECKOUT ====================

      case checkout:
        return _buildRoute(
          const CheckoutScreen(),
          routeSettings,
        );

// ==================== PROFILE ====================

      case profile:
        return _buildRoute(
          const ProfileScreen(),
          routeSettings,
        );

// ==================== WISHLIST ====================

      case wishlist:
        return _buildRoute(
          const FavoritesScreen(),
          routeSettings,
        );

// ==================== ORDERS ====================

      case orders:
        return _buildRoute(
          const OrdersScreen(),
          routeSettings,
        );

      case orderDetails:
        return _buildRoute(
          const OrdersScreen(),
          routeSettings,
        );

// ==================== ADDRESSES ====================

      case addresses:
        return _buildRoute(
          const AddressesScreen(),
          routeSettings,
        );

// ==================== SETTINGS ====================

      case settings:
        return _buildRoute(
          const ProfileScreen(),
          routeSettings,
        );

// ==================== NOTIFICATIONS ====================

      case notifications:
        return _buildRoute(
          const NotificationsScreen(),
          routeSettings,
        );

// ==================== EDIT PROFILE ====================

      case editProfile:
        return _buildRoute(
          const EditProfileScreen(),
          routeSettings,
        );

// ==================== PAYMENT METHODS ====================

      case paymentMethods:
        return _buildRoute(
          const PaymentMethodsScreen(),
          routeSettings,
        );

// ==================== ABOUT ====================

      case about:
        return _buildRoute(
          const AboutScreen(),
          routeSettings,
        );

// ==================== DEFAULT ====================

      default:
        return _buildRoute(
          const HomeScreen(),
          routeSettings,
        );
    }
  }

// ==================== ROUTE TRANSITION ====================

  static PageRouteBuilder _buildRoute(Widget page,
      RouteSettings routeSettings,) {
    return PageRouteBuilder(
      settings: routeSettings,

      pageBuilder: (context,
          animation,
          secondaryAnimation,) =>
      page,

      transitionsBuilder: (context,
          animation,
          secondaryAnimation,
          child,) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },

      transitionDuration:
      const Duration(milliseconds: 300),
    );
  }
}