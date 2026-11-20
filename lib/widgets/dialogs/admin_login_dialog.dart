import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

/// Shows the Admin Login flow.
/// When [startWithBiometric] is true (e.g. from the Side Menu), curious residents
/// first encounter the playful Biometric Fingerprint Scanner -> "Caught You!" prank,
/// while the real admin can tap straight into password entry at any time.
/// When [onVerifyPassword] is provided, wrong passwords keep the dialog open with
/// escalating funny roasts, shake animation, and a brief cooldown after 4 tries.
Future<String?> showAdminLoginDialog(
  BuildContext context,
  AppLocalizations s, {
  bool startWithBiometric = true,
  Future<bool> Function(String pass)? onVerifyPassword,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _AdminLoginDialog(
      s: s,
      startWithBiometric: startWithBiometric,
      onVerifyPassword: onVerifyPassword,
    ),
  );
}

enum _AdminLoginStep { biometric, caught, password }

class _AdminLoginDialog extends StatefulWidget {
  final AppLocalizations s;
  final bool startWithBiometric;
  final Future<bool> Function(String pass)? onVerifyPassword;

  const _AdminLoginDialog({
    required this.s,
    required this.startWithBiometric,
    this.onVerifyPassword,
  });

  @override
  State<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<_AdminLoginDialog>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  late _AdminLoginStep _step;
  bool _scanning = false;
  bool _verifying = false;
  int _wrongAttempts = 0;
  String? _roastMessage;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  Timer? _scanTimer;

  late final AnimationController _pulseCtrl;
  late final AnimationController _laserCtrl;
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _step = widget.startWithBiometric
        ? _AdminLoginStep.biometric
        : _AdminLoginStep.password;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _laserCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cooldownTimer?.cancel();
    _pulseCtrl.dispose();
    _laserCtrl.dispose();
    _shakeCtrl.dispose();
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeCtrl.forward(from: 0);
  }

  void _startFakeScan() {
    if (_scanning) return;
    setState(() => _scanning = true);
    _laserCtrl.repeat(reverse: true);
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 1150), () {
      if (!mounted) return;
      _laserCtrl.stop();
      setState(() {
        _scanning = false;
        _step = _AdminLoginStep.caught;
      });
      _triggerShake();
    });
  }

  void _goToPassword() {
    _scanTimer?.cancel();
    _laserCtrl.stop();
    setState(() {
      _scanning = false;
      _step = _AdminLoginStep.password;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  String _roastForAttempt(int attempt, String enteredValue) {
    final s = widget.s;
    switch (attempt) {
      case 1:
        return s.adminPrankRoast1;
      case 2:
        return s.adminPrankRoast2;
      case 3:
        return s.adminPrankRoast3(enteredValue);
      default:
        return s.adminPrankRoast4;
    }
  }

  Future<void> _submitPassword() async {
    if (_verifying || _cooldownSeconds > 0) return;
    final clean = _ctrl.text.trim();
    if (clean.isEmpty) {
      _triggerShake();
      return;
    }

    if (widget.onVerifyPassword == null) {
      Navigator.pop(context, clean);
      return;
    }

    setState(() => _verifying = true);
    final ok = await widget.onVerifyPassword!(clean);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, clean);
      return;
    }

    _wrongAttempts++;
    final roast = _roastForAttempt(_wrongAttempts, clean);
    _ctrl.clear();
    setState(() {
      _verifying = false;
      _roastMessage = roast;
    });
    _triggerShake();

    if (_wrongAttempts >= 4) {
      _cooldownTimer?.cancel();
      setState(() => _cooldownSeconds = 5);
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_cooldownSeconds <= 1) {
          timer.cancel();
          setState(() => _cooldownSeconds = 0);
          _focusNode.requestFocus();
        } else {
          setState(() => _cooldownSeconds--);
        }
      });
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        final dx = _shakeCtrl.isAnimating
            ? math.sin(_shakeCtrl.value * math.pi * 6) * 9 * (1 - _shakeCtrl.value)
            : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: switch (_step) {
                _AdminLoginStep.biometric => _buildBiometricStep(isDark),
                _AdminLoginStep.caught => _buildCaughtStep(isDark),
                _AdminLoginStep.password => _buildPasswordStep(isDark),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricStep(bool isDark) {
    final s = widget.s;
    return Column(
      key: const ValueKey('step_biometric'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.adminPrankBioTitle,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          s.adminPrankBioSub,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary(isDark),
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, _) {
                    final scale = 0.92 + (_pulseCtrl.value * 0.24);
                    final opacity = (1.0 - _pulseCtrl.value).clamp(0.0, 0.7);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: opacity),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _scanning ? null : _startFakeScan,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: isDark ? 0.24 : 0.14),
                            AppColors.primaryDark.withValues(alpha: isDark ? 0.34 : 0.18),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.65),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.fingerprint_rounded,
                            size: 50,
                            color: AppColors.primaryText(isDark),
                          ),
                          if (_scanning)
                            AnimatedBuilder(
                              animation: _laserCtrl,
                              builder: (_, _) {
                                final top = 12 + (_laserCtrl.value * 64);
                                return Positioned(
                                  top: top,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8),
                                      borderRadius: BorderRadius.circular(99),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xFF38BDF8),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _scanning ? s.adminPrankBioScanning : s.adminPrankBioPrompt,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: _scanning
                ? const Color(0xFF38BDF8)
                : AppColors.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Divider(height: 1, color: AppColors.border(isDark)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                s.cancel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _goToPassword,
              icon: Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: AppColors.primaryText(isDark),
              ),
              iconAlignment: IconAlignment.end,
              label: Text(
                s.adminPrankBioSkip,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryText(isDark),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaughtStep(bool isDark) {
    final s = widget.s;
    return Column(
      key: const ValueKey('step_caught'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.5),
              ),
            ),
            alignment: Alignment.center,
            child: const Text('🕵️‍♂️', style: TextStyle(fontSize: 30)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          s.adminPrankCaughtTitle,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.dangerText(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          s.adminPrankCaughtBody,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDark),
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: Text(
            s.adminPrankCaughtBackBtn,
            style: AppTypography.label.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: _goToPassword,
          child: Text(
            s.adminPrankCaughtRealBtn,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(bool isDark) {
    final s = widget.s;
    final disabled = _verifying || _cooldownSeconds > 0;
    final alertText = _roastMessage != null
        ? (_cooldownSeconds > 0
            ? '$_roastMessage\n${s.adminPrankCooldown(_cooldownSeconds)}'
            : _roastMessage!)
        : null;

    return Column(
      key: const ValueKey('step_password'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.adminLoginTitle,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          enabled: !disabled,
          obscureText: true,
          autofocus: true,
          textAlign: TextAlign.center,
          onSubmitted: (_) => _submitPassword(),
          style: AppTypography.title.copyWith(
            color: AppColors.textPrimary(isDark),
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: s.adminPassHint,
            filled: true,
            fillColor: AppColors.surface(isDark),
          ),
        ),
        if (alertText != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: isDark ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              alertText,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.dangerText(isDark),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _verifying ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.border(isDark)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  s.cancel,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textSecondary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: disabled ? null : _submitPassword,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: _verifying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        s.login,
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
