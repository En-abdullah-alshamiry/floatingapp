import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ============================================================
  // RESPONSIVE HELPERS
  // ============================================================

  double _screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  bool _isSmallScreen(BuildContext context) => _screenWidth(context) < 360;

  bool _isTablet(BuildContext context) => _screenWidth(context) >= 600;

  double _hPad(BuildContext context) {
    if (_isTablet(context)) return 80;
    if (_isSmallScreen(context)) return 16;
    return 24;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('البريد الإلكتروني أو كلمة المرور غير صحيحة')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', user.toMap().toString());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('success_login'))),
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.home, arguments: user);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في الاتصال: تأكد من تفعيل خيار Email/Password')),
      );
    }
  }

  void _onRegister() {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  Future<void> _onForgotPassword() async {
    final l10n = AppLocalizations.of(context);
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('enter_email'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    await AuthService().passwordReset(email: _emailController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tr('code_sent'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final pad = _hPad(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logoSize = _isSmallScreen(context) ? 96.0 : 120.0;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO
                    Center(
                      child: Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logos/imaglogo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.goldGradient,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'F',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: logoSize * 0.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      l10n.tr('login'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // EMAIL
                    _buildTextField(
                      controller: _emailController,
                      label: l10n.tr('email'),
                      hint: l10n.tr('enter_email'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                      colors: colors,
                      validator: (v) => (v?.isEmpty ?? true) ? l10n.tr('error_required_field') : null,
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    _buildTextField(
                      controller: _passwordController,
                      label: l10n.tr('password'),
                      hint: l10n.tr('enter_password'),
                      icon: Icons.lock_outlined,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      isDark: isDark,
                      colors: colors,
                      onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) => (v?.length ?? 0) < 6 ? l10n.tr('error_password') : null,
                    ),

                    // FORGOT PASSWORD
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: _onForgotPassword,
                        child: Text(
                          l10n.tr('forgot_password'),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // LOGIN BUTTON
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.black,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                l10n.tr('login'),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // DIVIDER
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.tr('or'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.outlineVariant)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SOCIAL BUTTONS
                    Row(
                      children: [
                        _buildSocialButton(
                          label: 'Google',
                          icon: Icons.g_mobiledata,
                          onPressed: () => _handleSocialLogin(AuthService().loginWithGoogle),
                          colors: colors,
                        ),
                        const SizedBox(width: 12),
                        _buildSocialButton(
                          label: 'Facebook',
                          icon: Icons.facebook,
                          iconColor: const Color(0xFF1877F2),
                          onPressed: () => _handleSocialLogin(AuthService().loginWithFacebook),
                          colors: colors,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // REGISTER LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.tr('dont_have_account'),
                          style: GoogleFonts.inter(fontSize: 14, color: colors.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: _onRegister,
                          child: Text(
                            l10n.tr('register'),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(Future<UserModel?> Function() method) async {
    setState(() => _isLoading = true);
    final user = await method();
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', user.toMap().toString());
      Navigator.of(context).pushReplacementNamed(AppRoutes.home, arguments: user);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
    required ColorScheme colors,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 15, color: colors.onSurface),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.gold),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: isDark ? 0.3 : 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onPressed,
    required ColorScheme colors,
  }) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor ?? AppColors.gold, size: 24),
          label: Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}
