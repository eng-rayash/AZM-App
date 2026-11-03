import 'package:flutter/material.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';

/// AZM — هيكل الشاشة
///
/// شاشات عزم بلا `AppBar` بمعناه المادّي: لا سطح ملوّن ولا ارتفاع ولا ظل.
/// العنوان جزء من المحتوى ويمرّ تحت التمرير، وهو ما يمنح الشاشة هدوءها
/// ويترك ارتفاع الجوال للمحتوى لا للزخرفة.
///
/// كل شاشة لها إجراء أساسي واحد ([primaryAction]) — لا أكثر. ما عداه
/// يعيش داخل السياق الذي يخصّه.
class AzmScreen extends StatelessWidget {
  const AzmScreen({
    super.key,
    required this.title,
    required this.slivers,
    this.caption,
    this.primaryAction,
    this.leading,
  });

  /// عنوان الشاشة — اسم لا جملة
  final String title;

  /// سطر واحد يشرح ما تجيب عنه الشاشة
  final String? caption;

  /// الإجراء الأساسي الوحيد — أعلى اليسار في اتجاه RTL
  final Widget? primaryAction;

  /// عنصر في بداية سطر العنوان (رجوع، صورة رمزية)
  final Widget? leading;

  /// محتوى الشاشة
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AzmSpace.screenGutter,
                  AzmSpace.xl,
                  AzmSpace.screenGutter,
                  AzmSpace.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: AzmSpace.md),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.h1.copyWith(
                              color: p.ink,
                              fontSize: 30,
                              height: 1.25,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (caption != null) ...[
                            const SizedBox(height: AzmSpace.xs),
                            Text(
                              caption!,
                              style: AppTypography.bodySmall.copyWith(
                                color: p.inkFaint,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (primaryAction != null) ...[
                      const SizedBox(width: AzmSpace.md),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: primaryAction!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ...slivers,
            // خلوص أسفل الشاشة — الشريط والزرّ العائم معًا. `SafeArea
            // (bottom: false)` أعلاه يترك الحافة السفلى للشريط نفسه.
            const SliverToBoxAdapter(
              child: SizedBox(height: AzmSpace.scrollBottomInset),
            ),
          ],
        ),
      ),
    );
  }
}

/// زرّ أيقونة صامت — بلا تعبئة ولا حدّ حتى يُضغط.
class AzmIconAction extends StatelessWidget {
  const AzmIconAction({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// نصّ الوصول — إلزامي: زرّ أيقونة بلا تسمية لا يقرأه قارئ الشاشة
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AzmRadius.control,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 21, color: p.ink),
        ),
      ),
    );
  }
}
