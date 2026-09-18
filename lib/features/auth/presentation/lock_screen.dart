import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/security/lock_manager.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../shared/widgets/app_logo.dart';

/// Lock Screen — biometric + PIN authentication.
///
/// Features:
/// - Auto-biometric attempt on load (if enabled)
/// - Correct ATM-style PIN pad layout (1-2-3 / 4-5-6 / 7-8-9 / DEL-0-OK)
/// - Animated NeuButton press effect (150ms cubic-bezier)
/// - Lockout after max failed attempts
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _authService = AuthService.instance;
  String _pin = '';
  bool _hasError = false;
  String _errorMessage = '';
  int _failedAttempts = 0;
  bool _isLocked = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isBiometricAvailable = await _authService.isBiometricAvailable();
    final method = await _authService.getPreferredAuthMethod();
    // Auto-attempt biometric if enabled (method == 0)
    if (_isBiometricAvailable && method == 0) {
      _attemptBiometric();
    }
    if (mounted) setState(() {});
  }

  Future<void> _attemptBiometric() async {
    final ok = await _authService.authenticateWithBiometrics();
    if (ok && mounted) _unlockAndNavigate();
  }

  void _onDigit(int d) {
    if (_isLocked) return;
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      if (_pin.length < AppConstants.pinLength) _pin += d.toString();
    });
    if (_pin.length == AppConstants.pinLength) _verifyPin();
  }

  void _onDelete() {
    if (_isLocked) return;
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _onConfirm() {
    if (_isLocked || _pin.length < AppConstants.pinLength) return;
    _verifyPin();
  }

  Future<void> _verifyPin() async {
    if (await _authService.verifyPin(_pin)) {
      _unlockAndNavigate();
    } else {
      _failedAttempts++;
      HapticFeedback.heavyImpact();
      if (_failedAttempts >= AppConstants.maxWrongAttempts) {
        setState(() {
          _isLocked = true;
          _hasError = true;
          _errorMessage =
              'تم تجاوز الحد. انتظر ${AppConstants.lockoutMinutes} دقائق';
          _pin = '';
        });
        Future.delayed(Duration(minutes: AppConstants.lockoutMinutes), () {
          if (mounted) {
            setState(() {
              _isLocked = false;
              _failedAttempts = 0;
              _hasError = false;
            });
          }
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage =
              'رمز خاطئ (${AppConstants.maxWrongAttempts - _failedAttempts} متبقية)';
          _pin = '';
        });
      }
    }
  }

  void _unlockAndNavigate() {
    LockManager.instance.unlock();
    context.go(RouteNames.dashboardFull);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: AzmMark(size: 80, isDark: isDark),
              ),

              AppSpacing.gapXxl,

              Text(
                'مرحبًا بك',
                style: isDark ? AppTypography.h2Dark : AppTypography.h2,
              ),
              AppSpacing.gapSm,
              Text(
                'أدخل رمز الدخول',
                style: (isDark ? AppTypography.bodyDark : AppTypography.body)
                    .copyWith(
                      color: isDark
                          ? NeuColors.textSecondaryDark
                          : NeuColors.textSecondary,
                    ),
              ),

              AppSpacing.gapXxxl,

              // PIN Dots
              _buildPinDots(isDark),

              // Error message
              if (_hasError) ...[
                AppSpacing.gapLg,
                Text(
                  _errorMessage,
                  style: AppTypography.bodySmall.copyWith(
                    color: NeuColors.danger,
                  ),
                ),
              ],

              const Spacer(),

              // ATM-style Number Pad
              _buildNumPad(isDark),

              // Biometric button
              if (_isBiometricAvailable && !_isLocked) ...[
                AppSpacing.gapLg,
                GestureDetector(
                  onTap: _attemptBiometric,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: NeuDecorations.neuFlatSoft(
                      radius: 50,
                      isDark: isDark,
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 32,
                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                    ),
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  'استخدم البصمة',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(bool isDark) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(AppConstants.pinLength, (i) {
      final filled = i < _pin.length;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: filled ? 18 : 14,
        height: filled ? 18 : 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _hasError
              ? NeuColors.danger
              : (filled
                    ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                    : Colors.transparent),
          border: Border.all(
            color: _hasError
                ? NeuColors.danger
                : (filled
                      ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                      : (isDark
                            ? NeuColors.shadowLightDark
                            : NeuColors.shadowDark)),
            width: 2,
          ),
        ),
      );
    }),
  );

  /// ATM-style layout (RTL - عكسي):
  /// [3][2][1]
  /// [6][5][4]
  /// [9][8][7]
  /// [OK][0][DEL]
  Widget _buildNumPad(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 48),
    child: Column(
      children: [
        _numRow([3, 2, 1], isDark),
        AppSpacing.gapMd,
        _numRow([6, 5, 4], isDark),
        AppSpacing.gapMd,
        _numRow([9, 8, 7], isDark),
        AppSpacing.gapMd,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // CONFIRM button
            _PadButton(
              isDark: isDark,
              onTap: _pin.length == AppConstants.pinLength ? _onConfirm : null,
              child: Icon(
                Icons.check_rounded,
                color: _pin.length == AppConstants.pinLength
                    ? NeuColors.success
                    : (isDark ? NeuColors.textHintDark : NeuColors.textHint),
                size: 28,
              ),
            ),
            // ZERO button
            _numBtn(0, isDark),
            // DELETE button
            _PadButton(
              isDark: isDark,
              onTap: _onDelete,
              child: Icon(
                Icons.backspace_outlined,
                color: isDark
                    ? NeuColors.textSecondaryDark
                    : NeuColors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _numRow(List<int> d, bool isDark) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: d.map((n) => _numBtn(n, isDark)).toList(),
  );

  Widget _numBtn(int d, bool isDark) => _PadButton(
    isDark: isDark,
    onTap: () => _onDigit(d),
    child: Text(
      d.toString(),
      style: (isDark ? AppTypography.h2Dark : AppTypography.h2).copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

/// Animated PIN Pad Button with Neumorphic press effect.
class _PadButton extends StatefulWidget {
  const _PadButton({required this.isDark, required this.child, this.onTap});

  final bool isDark;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_PadButton> createState() => _PadButtonState();
}

class _PadButtonState extends State<_PadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final decoration = _isPressed
        ? NeuDecorations.neuPressed(radius: 36, isDark: widget.isDark)
        : NeuDecorations.neuFlatSoft(radius: 36, isDark: widget.isDark);

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: 72,
        height: 72,
        decoration: decoration,
        child: Center(child: widget.child),
      ),
    );
  }
}