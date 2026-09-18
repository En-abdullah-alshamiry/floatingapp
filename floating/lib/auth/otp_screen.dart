import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';
import '../config/routes.dart';
import '../l10n/app_localizations.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _codeLength = 4;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  String _email = '';
  int _timerSeconds = 30;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_email.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        _email = args;
      }
    }
  }

  String get _code {
    return _controllers.map((c) => c.text.trim()).join();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _onVerify() async {
    final l10n = AppLocalizations.of(context);
    if (_code.length != _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('error_otp'))),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.resetPassword);
  }

  void _onResend() {
    if (!_canResend) return;
    _startTimer();
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.tr('code_sent'))),
    );
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
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
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
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
                        Icons.mark_email_unread_outlined,
                        size: 50,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      l10n.tr('otp_title'),
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
                    child: Text.rich(
                      TextSpan(
                        text: '${l10n.tr('otp_desc')} ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.7,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        children: [
                          TextSpan(
                            text: _email.isEmpty ? 'example@email.com' : _email,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildOtpFields(),
                  const SizedBox(height: 36),
                  _buildVerifyButton(l10n),
                  const SizedBox(height: 24),
                  _buildResendRow(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }

  // ==================== OTP FIELDS ====================
  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_codeLength, (index) {
        return SizedBox(
          width: 62,
          height: 64,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: AppColors.gold,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              filled: true,
              fillColor: null,
              focusedErrorBorder: null,
              enabledBorder: null,
            ),
            onChanged: (value) => _onChanged(index, value),
          ),
        );
      }),
    );
  }

  // ==================== VERIFY BUTTON ====================
  Widget _buildVerifyButton(AppLocalizations l10n) {
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
            onTap: _isLoading ? null : _onVerify,
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
                      l10n.tr('verify'),
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

  // ==================== RESEND ====================
  Widget _buildResendRow(AppLocalizations l10n) {
    return Center(
      child: _canResend
          ? TextButton(
              onPressed: _onResend,
              child: Text(l10n.tr('resend_code')),
            )
          : Text.rich(
              TextSpan(
                text: '${l10n.tr('resend_in')} ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                children: [
                  TextSpan(
                    text: '00:${_timerSeconds.toString().padLeft(2, '0')}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}