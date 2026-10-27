import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/azm_tokens.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_typography.dart';

/// AZM — عرض حالة غير متزامنة في شاشات المتاجر
///
/// ## لماذا طبقة خاصة بالمتاجر
///
/// بقية التطبيق يقرأ من Drift فلا «يفشل» الجلب: البيانات محليّة. أما
/// المتاجر فتقرأ من الخادم مباشرة — الطلب يأتي من زائر لحظةً بلحظة،
/// والمخزون ينقص بطلب لم يمرّ بهذا الجهاز.
///
/// وهذا يعني أن **انقطاع الاتصال حالة متوقَّعة لا عطب**، ويجب أن
/// تُقال صراحةً. الخطأ الذي كان سيقع لولا ذلك: عرض قائمة فارغة عند
/// انقطاع الشبكة، فيقرؤها التاجر «لا طلبات» ويطمئنّ — وعنده طلبات
/// تنتظر.
///
/// فالتمييز هنا ثلاثي لا ثنائي:
///   • انقطاع → «لا اتصال» + إعادة محاولة. ليس خطأً.
///   • ٤٠١ → «انتهت الجلسة» + دخول. إعادة المحاولة لا تُجدي.
///   • غير ذلك → رسالة الخادم كما هي، لأنها بالعربية وتعرف السبب.
class ShopAsync<T> extends StatelessWidget {
  const ShopAsync({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
    this.empty,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  /// إعادة الجلب — عادةً `ref.invalidate(theProvider)`.
  final VoidCallback onRetry;

  /// ما يُعرض حين لا بيانات. يحتاج [isEmpty] ليُعرف «لا بيانات».
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: true,
      loading: () => const _Centered(child: _Spinner()),
      error: (e, _) => _Centered(child: ShopFailure(error: e, onRetry: onRetry)),
      data: (data) {
        if (empty != null && (isEmpty?.call(data) ?? false)) {
          return _Centered(child: empty!);
        }
        return builder(data);
      },
    );
  }
}

/// نسخة تُستخدم داخل `CustomScrollView`.
class ShopAsyncSliver<T> extends StatelessWidget {
  const ShopAsyncSliver({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
    this.empty,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: true,
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AzmSpace.xxxl),
          child: _Spinner(),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AzmSpace.screenGutter),
          child: ShopFailure(error: e, onRetry: onRetry),
        ),
      ),
      data: (data) {
        if (empty != null && (isEmpty?.call(data) ?? false)) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AzmSpace.screenGutter),
              child: empty!,
            ),
          );
        }
        return builder(data);
      },
    );
  }
}

/// بطاقة فشل تقول **ما حدث وما يُفعل**.
class ShopFailure extends StatelessWidget {
  const ShopFailure({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final (icon, title, body, tone, canRetry) = _describe(error, p);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: tone),
        const SizedBox(height: AzmSpace.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(color: p.ink),
        ),
        const SizedBox(height: AzmSpace.xs),
        Text(
          body,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: p.inkMuted),
        ),
        if (canRetry) ...[
          const SizedBox(height: AzmSpace.lg),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
            style: TextButton.styleFrom(foregroundColor: p.accent),
          ),
        ],
      ],
    );
  }

  /// أيقونة · عنوان · شرح · لون · هل تُجدي الإعادة؟
  ///
  /// `isRetryable` يأتي من [ApiException] لا من تخمين الواجهة: نفس
  /// التصنيف الذي يستعمله محرّك المزامنة، فلا موضعان يقرّران.
  (IconData, String, String, Color, bool) _describe(
    Object e,
    AzmPalette p,
  ) {
    if (e is NetworkUnreachable) {
      return (
        Icons.cloud_off_rounded,
        'لا اتصال بالخادم',
        'بيانات المتجر تُقرأ من الخادم لحظةً بلحظة — الطلبات تأتي من '
            'زوّار متجرك، والمخزون ينقص بطلب قد لا يمرّ بهذا الجهاز. '
            'لذلك لا تُحفظ نسخة محلية قد تضلّلك.',
        p.inkMuted,
        true,
      );
    }
    if (e is Unauthenticated) {
      return (
        Icons.lock_outline_rounded,
        'انتهت الجلسة',
        e.message,
        p.warning,
        false,
      );
    }
    if (e is Forbidden) {
      return (
        Icons.shield_outlined,
        'صلاحيتك لا تكفي',
        e.message,
        p.warning,
        false,
      );
    }
    if (e is NotFound) {
      return (
        Icons.search_off_rounded,
        'غير موجود',
        e.message,
        p.inkMuted,
        false,
      );
    }
    if (e is ApiException) {
      return (
        Icons.error_outline_rounded,
        'تعذّر إكمال الطلب',
        e.message,
        p.danger,
        e.isRetryable,
      );
    }
    // خطأ غير متوقَّع: لا نلفّقه برسالة ودّية تُخفي سببه
    return (
      Icons.error_outline_rounded,
      'خطأ غير متوقَّع',
      '$e',
      p.danger,
      true,
    );
  }
}

/// حالة «لا شيء بعد» — تقول ما يُفعل لا «فارغ».
class ShopEmpty extends StatelessWidget {
  const ShopEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: p.inkGhost),
        const SizedBox(height: AzmSpace.md),
        Text(title, style: AppTypography.h3.copyWith(color: p.ink)),
        const SizedBox(height: AzmSpace.xs),
        Text(
          body,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: p.inkMuted),
        ),
        if (action != null) ...[
          const SizedBox(height: AzmSpace.lg),
          action!,
        ],
      ],
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AzmSpace.xl),
          child: child,
        ),
      );
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AzmPalette.of(context).accent,
          ),
        ),
      );
}

/// يعرض نتيجة إجراء — نجاحًا أو فشلًا — بلا ادّعاء نجاح.
///
/// القاعدة التي يفرضها هذا المساعد: **لا `Fake Success`.** الإجراء
/// يُنفَّذ، فإن رمى عُرض سببه الحقيقي من رسالة الخادم. الصيغة التي
/// كانت تُنتج العطب: `try { await x() } catch (_) {}` ثم شريط «تمّ».
Future<bool> runShopAction(
  BuildContext context, {
  required Future<void> Function() action,
  required String success,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final p = AzmPalette.of(context);

  try {
    await action();
    if (!context.mounted) return true;
    messenger.showSnackBar(
      SnackBar(
        content: Text(success),
        backgroundColor: p.ink,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return true;
  } on ApiException catch (e) {
    if (!context.mounted) return false;
    messenger.showSnackBar(
      SnackBar(
        // رسالة الخادم لا رسالتنا: هي تعرف السبب وتقول ما يُفعل
        content: Text(e.message),
        backgroundColor: p.danger,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
    return false;
  }
}
