import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';

/// Change PIN Page — 3-step flow:
/// 1. Enter current PIN
/// 2. Enter new PIN
/// 3. Confirm new PIN
///
/// Uses same ATM-style keypad as lock screen.
class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

enum _ChangePinStep { current, newPin, confirm }

class _ChangePinPageState extends State<ChangePinPage> {
  final _authService = AuthService.instance;

  _ChangePinStep _step = _ChangePinStep.current;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  bool _hasError = false;
  String _errorMessage = '';

  String get _activePin {
    switch (_step) {
      case _ChangePinStep.current:
        return _currentPin;
      case _ChangePinStep.newPin:
        return _newPin;
      case _ChangePinStep.confirm:
        return _confirmPin;
    }
  }

  String get _title {
    switch (_step) {
      case _ChangePinStep.current:
        return 'أدخل الرمز الحالي';
      case _ChangePinStep.newPin:
        return 'أدخل الرمز الجديد';
      case _ChangePinStep.confirm:
        return 'تأكيد الرمز الجديد';
    }
  }

  void _onDigit(int d) {
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      switch (_step) {
        case _ChangePinStep.current:
          if (_currentPin.length < AppConstants.pinLength) {
            _currentPin += d.toString();
          }
          if (_currentPin.length == AppConstants.pinLength) {
            _verifyCurrent();
          }
          break;
        case _ChangePinStep.newPin:
          if (_newPin.length < AppConstants.pinLength) {
            _newPin += d.toString();
          }
          if (_newPin.length == AppConstants.pinLength) {
            _step = _ChangePinStep.confirm;
          }
          break;
        case _ChangePinStep.confirm:
          if (_confirmPin.length < AppConstants.pinLength) {
            _confirmPin += d.toString();
          }
          if (_confirmPin.length == AppConstants.pinLength) {
            _validateAndSave();
          }
          break;
      }
    });
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      switch (_step) {
        case _ChangePinStep.current:
          if (_currentPin.isNotEmpty) {
            _currentPin = _currentPin.substring(0, _currentPin.length - 1);
          }
          break;
        case _ChangePinStep.newPin:
          if (_newPin.isNotEmpty) {
            _newPin = _newPin.substring(0, _newPin.length - 1);
          }
          break;
        case _ChangePinStep.confirm:
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
          break;
      }
    });
  }

  Future<void> _verifyCurrent() async {
    final ok = await _authService.verifyPin(_currentPin);
    if (ok) {
      setState(() => _step = _ChangePinStep.newPin);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorMessage = 'الرمز الحالي غير صحيح';
        _currentPin = '';
      });
    }
  }

  Future<void> _validateAndSave() async {
    if (_newPin == _confirmPin) {
      await _authService.setupPin(_newPin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('تم تغيير رمز الدخول بنجاح'),
              ],
            ),
            backgroundColor: NeuColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorMessage = 'الرمز غير متطابق، حاول مرة أخرى';
        _confirmPin = '';
        _newPin = '';
        _step = _ChangePinStep.newPin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'تغيير رمز الدخول',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Step indicator
              _buildStepIndicator(isDark),

              AppSpacing.gapXxl,

              // Title
              Text(
                _title,
                style: isDark ? AppTypography.h2Dark : AppTypography.h2,
              ),

              AppSpacing.gapXxxl,

              // PIN dots
              _buildPinDots(isDark),

              // Error
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

              // Keypad
              _buildNumPad(isDark),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = [
      _ChangePinStep.current,
      _ChangePinStep.newPin,
      _ChangePinStep.confirm,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (i) {
        final isActive = steps.indexOf(_step) >= i;
        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                    : Colors.transparent,
                border: Border.all(
                  color: isActive
                      ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                      : (isDark ? NeuColors.textHintDark : NeuColors.textHint),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? NeuColors.textOnDark
                        : (isDark
                              ? NeuColors.textHintDark
                              : NeuColors.textHint),
                  ),
                ),
              ),
            ),
            if (i < steps.length - 1)
              Container(
                width: 32,
                height: 2,
                color: isActive
                    ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                    : (isDark ? NeuColors.dividerDark : NeuColors.divider),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildPinDots(bool isDark) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(AppConstants.pinLength, (i) {
      final filled = i < _activePin.length;
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
            const SizedBox(width: 72, height: 72),
            _numBtn(0, isDark),
            _buildPadBtn(
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

  Widget _numBtn(int d, bool isDark) => _buildPadBtn(
    isDark: isDark,
    onTap: () => _onDigit(d),
    child: Text(
      d.toString(),
      style: (isDark ? AppTypography.h2Dark : AppTypography.h2).copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildPadBtn({
    required bool isDark,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return _AnimatedPadButton(isDark: isDark, onTap: onTap, child: child);
  }
}

class _AnimatedPadButton extends StatefulWidget {
  const _AnimatedPadButton({
    required this.isDark,
    required this.child,
    this.onTap,
  });

  final bool isDark;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_AnimatedPadButton> createState() => _AnimatedPadButtonState();
}

class _AnimatedPadButtonState extends State<_AnimatedPadButton> {
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