import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tr('code_sent'))),
    );
    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: _emailController.text.trim(),
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
                          Icons.lock_reset_rounded,
                          size: 50,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Text(
                        l10n.tr('forgot_password'),
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
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      style: GoogleFonts.inter(fontSize: 14),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return l10n.tr('error_required_field');
                        if (!RegExp(r'^[\w\.-]+@[\w-]+\.\w+$').hasMatch(text)) {
                          return l10n.tr('error_email');
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: l10n.tr('email'),
                        hintText: l10n.tr('email_hint'),
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                      ),
                      onFieldSubmitted: (_) => _onSend(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
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
                            onTap: _isLoading ? null : _onSend,
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
                                      l10n.tr('send_code'),
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
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text(l10n.tr('back_to_login')),
                      ),
                    ),
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
}