import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tr('success_profile'))),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkAccent.withValues(alpha: 0.08), bg]
                : [AppColors.lightGold.withValues(alpha: 0.12), bg],
          ),
        ),
        child: Directionality(
          textDirection: l10n.textDirection,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.4),
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_open_rounded,
                          size: 50,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Text(
                        l10n.tr('reset_password'),
                        style: (isArabic
                                ? GoogleFonts.notoSansArabic()
                                : GoogleFonts.playfairDisplay())
                            .copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        l10n.tr('forgot_password_desc'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.7,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildNewPasswordField(l10n),
                    const SizedBox(height: 16),
                    _buildConfirmField(l10n),
                    const SizedBox(height: 28),
                    _buildSubmitButton(l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }

  // ==================== NEW PASSWORD ====================
  Widget _buildNewPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: _newPassController,
      obscureText: _obscureNew,
      textInputAction: TextInputAction.next,
      style: GoogleFonts.inter(fontSize: 14),
      validator: (value) {
        if ((value ?? '').isEmpty) return l10n.tr('error_required_field');
        if ((value?.trim().length ?? 0) < 8) return l10n.tr('error_password');
        return null;
      },
      decoration: InputDecoration(
        labelText: l10n.tr('new_password'),
        hintText: l10n.tr('password_hint'),
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: l10n.tr('toggle_password'),
          onPressed: () => setState(() => _obscureNew = !_obscureNew),
          icon: Icon(
            _obscureNew
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
        ),
      ),
    );
  }

  // ==================== CONFIRM PASSWORD ====================
  Widget _buildConfirmField(AppLocalizations l10n) {
    return TextFormField(
      controller: _confirmPassController,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      style: GoogleFonts.inter(fontSize: 14),
      validator: (value) {
        if ((value ?? '').isEmpty) return l10n.tr('error_required_field');
        if (value != _newPassController.text) {
          return l10n.tr('error_password_match');
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: l10n.tr('confirm_new_password'),
        hintText: l10n.tr('password_hint'),
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: l10n.tr('toggle_password'),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          icon: Icon(
            _obscureConfirm
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
        ),
      ),
      onFieldSubmitted: (_) => _onSubmit(),
    );
  }

  // ==================== SUBMIT ====================
  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isLoading ? null : _onSubmit,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.black,
                      ),
                    )
                  : Text(
                      l10n.tr('save'),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}