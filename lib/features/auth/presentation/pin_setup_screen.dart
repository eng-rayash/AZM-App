import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';

/// PIN Setup Screen — shown on first launch.
///
/// Guides the user through:
/// 1. Create a 6-digit PIN
/// 2. Confirm the PIN
/// 3. Optional: Enable biometric authentication
/// 4. Navigate to Dashboard
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _authService = AuthService.instance;

  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _showBiometricOption = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _authService.isBiometricAvailable();
    if (mounted) {
      setState(() => _showBiometricOption = available);
    }
  }

  void _onDigitPressed(int digit) {
    HapticFeedback.lightImpact();

    setState(() {
      _hasError = false;
      _errorMessage = '';

      if (_isConfirming) {
        if (_confirmPin.length < AppConstants.pinLength) {
          _confirmPin += digit.toString();
        }
        if (_confirmPin.length == AppConstants.pinLength) {
          _validatePins();
        }
      } else {
        if (_pin.length < AppConstants.pinLength) {
          _pin += digit.toString();
        }
        if (_pin.length == AppConstants.pinLength) {
          _isConfirming = true;
        }
      }
    });
  }

  void _onDeletePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _validatePins() async {
    if (_pin == _confirmPin) {
      await _authService.setupPin(_pin);
      await _authService.completeFirstLaunch();

      if (_showBiometricOption && mounted) {
        _promptBiometric();
      } else if (mounted) {
        context.go(RouteNames.dashboardFull);
      }
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'الرمز غير متطابق، حاول مرة أخرى';
        _confirmPin = '';
        _isConfirming = false;
        _pin = '';
      });
    }
  }

  Future<void> _promptBiometric() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.dark
              ? NeuColors.bgColorDark
              : NeuColors.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'تفعيل البصمة',
            style: Theme.of(ctx).brightness == Brightness.dark
                ? AppTypography.h3Dark
                : AppTypography.h3,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل تريد استخدام البصمة للدخول السريع؟',
            style: Theme.of(ctx).brightness == Brightness.dark
                ? AppTypography.bodyDark
                : AppTypography.body,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'لاحقًا',
                style:
                    (Theme.of(ctx).brightness == Brightness.dark
                            ? AppTypography.bodyDark
                            : AppTypography.body)
                        .copyWith(
                          color: Theme.of(ctx).brightness == Brightness.dark
                              ? NeuColors.textSecondaryDark
                              : NeuColors.textSecondary,
                        ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('تفعيل'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final authenticated = await _authService.authenticateWithBiometrics();
      if (authenticated) {
        await _authService.setPreferredAuthMethod(0); // biometric
      }
    }

    if (mounted) {
      context.go(RouteNames.dashboardFull);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Title
              Text(
                _isConfirming ? 'تأكيد الرمز' : 'إنشاء رمز الدخول',
                style: isDark ? AppTypography.h2Dark : AppTypography.h2,
              ),
              AppSpacing.gapMd,
              Text(
                _isConfirming
                    ? 'أعد إدخال الرمز للتأكيد'
                    : 'أدخل رمزًا مكونًا من ٦ أرقام',
                style: (isDark ? AppTypography.bodyDark : AppTypography.body)
                    .copyWith(
                      color: isDark
                          ? NeuColors.textSecondaryDark
                          : NeuColors.textSecondary,
                    ),
              ),

              AppSpacing.gapXxxl,

              // PIN Dots
              _buildPinDots(currentPin, isDark),

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

              const Spacer(flex: 1),

              // Number Pad
              _buildNumberPad(isDark),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(String currentPin, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(AppConstants.pinLength, (index) {
        final isFilled = index < currentPin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 18 : 14,
          height: isFilled ? 18 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hasError
                ? NeuColors.danger
                : (isFilled
                      ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                      : Colors.transparent),
            border: Border.all(
              color: _hasError
                  ? NeuColors.danger
                  : (isFilled
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
  }

  Widget _buildNumberPad(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _buildNumberRow([3, 2, 1], isDark),
          AppSpacing.gapMd,
          _buildNumberRow([6, 5, 4], isDark),
          AppSpacing.gapMd,
          _buildNumberRow([9, 8, 7], isDark),
          AppSpacing.gapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Empty space
              const SizedBox(width: 72, height: 72),
              // Zero
              _buildNumberButton(0, isDark),
              // Delete
              _buildDeleteButton(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<int> digits, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumberButton(d, isDark)).toList(),
    );
  }

  Widget _buildNumberButton(int digit, bool isDark) {
    return GestureDetector(
      onTap: () => _onDigitPressed(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: NeuDecorations.neuFlatSoft(radius: 36, isDark: isDark),
        child: Center(
          child: Text(
            digit.toString(),
            style: (isDark ? AppTypography.h2Dark : AppTypography.h2).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(bool isDark) {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: isDark
                ? NeuColors.textSecondaryDark
                : NeuColors.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }
}