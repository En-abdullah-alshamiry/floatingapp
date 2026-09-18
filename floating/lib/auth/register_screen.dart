import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tr('registration_failed'))),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('account_created'))),
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('registration_failed'))),
      );
    }
  }

  void _onLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final pad = _hPad(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logoSize = _isSmallScreen(context) ? 80.0 : 100.0;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
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
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 30,
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

                    const SizedBox(height: 24),

                    Text(
                      l10n.tr('create_account'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // FULL NAME
                    _buildTextField(
                      controller: _nameController,
                      label: l10n.tr('full_name'),
                      hint: l10n.tr('name_hint'),
                      icon: Icons.person_outline,
                      isDark: isDark,
                      colors: colors,
                      validator: (v) => (v?.isEmpty ?? true)
                          ? l10n.tr('error_required_field')
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // EMAIL
                    _buildTextField(
                      controller: _emailController,
                      label: l10n.tr('email'),
                      hint: l10n.tr('email_hint'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                      colors: colors,
                      validator: (v) {
                        if (v?.isEmpty ?? true) return l10n.tr('error_required_field');
                        if (!RegExp(r'^[\w\.-]+@[\w-]+\.\w+$').hasMatch(v!)) {
                          return l10n.tr('error_invalid_email');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // PHONE
                    _buildTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      hint: '05xxxxxxxx',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                      colors: colors,
                      validator: (v) => (v?.length ?? 0) < 9
                          ? 'رقم الهاتف غير صحيح'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD
                    _buildTextField(
                      controller: _passwordController,
                      label: l10n.tr('password'),
                      hint: l10n.tr('password_hint'),
                      icon: Icons.lock_outlined,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      isDark: isDark,
                      colors: colors,
                      onToggleVisibility: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (v) => (v?.length ?? 0) < 6
                          ? l10n.tr('error_password')
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    _buildTextField(
                      controller: _confirmController,
                      label: l10n.tr('confirm_password'),
                      hint: l10n.tr('password_hint'),
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      obscureText: _obscureConfirm,
                      isDark: isDark,
                      colors: colors,
                      onToggleVisibility: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => v != _passwordController.text
                          ? l10n.tr('password_not_match')
                          : null,
                    ),

                    const SizedBox(height: 32),

                    // REGISTER BUTTON
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onRegister,
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
                                l10n.tr('register'),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.tr('has_account'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: _onLogin,
                          child: Text(
                            l10n.tr('login'),
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
        fillColor: colors.surfaceContainerHighest
            .withValues(alpha: isDark ? 0.3 : 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
      ),
    );
  }
}
