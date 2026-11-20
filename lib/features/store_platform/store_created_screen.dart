import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/azm_tokens.dart';
import '../../shared/widgets/rvios_brand.dart';
import '../store_app/kit.dart';
import '../store_app/store_routes.dart';
import '../store_tools/store_tools_api.dart' show storefrontUrl;
import 'design_studio_screen.dart';
import 'payment_methods_screen.dart';
import 'platform_catalog.dart';
import 'platform_widgets.dart';

/// بعد الإنشاء: المجاني يعمل الآن برابطه، والمدفوع «طلب» ينتظر الدفع والتفعيل.
class StoreCreatedScreen extends StatelessWidget {
  const StoreCreatedScreen({
    super.key,
    required this.storeId,
    required this.name,
    required this.slug,
    required this.template,
    required this.plan,
    required this.total,
    required this.currency,
    this.waNumber,
    this.waMessage,
  });

  final String storeId;
  final String name;
  final String slug;
  final StoreTemplate template;
  final PlanId plan;
  final num total;
  final String currency;
  final String? waNumber;
  final String? waMessage;

  String get _url => '$storefrontUrl/s/$slug';

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final paid = plan.paid;
    void home() {
      Navigator.of(context).popUntil((r) => r.isFirst);
      GoRouter.of(context).go(StoreRoutes.home);
    }

    return Scaffold(
      backgroundColor: p.ground,
      body: ListView(padding: EdgeInsets.zero, children: [
        // ── البطل ──
        Container(
          decoration: const BoxDecoration(gradient: Rv.heroGradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(40))),
          padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 30, 24, 34),
          child: Column(children: [
            const AnimatedRvMark(width: 130, color: RvBrand.cream, glow: true),
            const SizedBox(height: 22),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1600),
              curve: const Interval(.45, 1, curve: Curves.easeOutCubic),
              builder: (context, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child)),
              child: Column(children: [
                Text(paid ? 'طلبك وصل الفريق 🎉' : 'متجرك جاهز 🎉',
                    textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Zain', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15)),
                const SizedBox(height: 8),
                Text(
                  paid
                      ? 'حجزنا «$name» ورابطه. أكمل الدفع على واتساب، فيتفعّل متجرك ويصلك إشعار.'
                      : '«$name» يعمل الآن ويستقبل الطلبات. أضف منتجاتك وشارك الرابط مع عملائك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: .85), height: 1.6),
                ),
                const SizedBox(height: 18),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _url));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نُسخ رابط المتجر')));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.link_rounded, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Flexible(child: Text('$slug.rvios.com', textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                      const SizedBox(width: 8),
                      const Icon(Icons.copy_rounded, color: Colors.white70, size: 16),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (paid) ...[
              RvCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    const RvChip('بانتظار التفعيل', color: Color(0xFFD97706)),
                    const Spacer(),
                    Text('${currencyLabel(currency)}${fmtMoney(total)}', style: const TextStyle(fontFamily: 'Zain', fontSize: 26, fontWeight: FontWeight.w800, color: Rv.red)),
                  ]),
                  const SizedBox(height: 14),
                  const HowSteps([
                    ('أُرسل الطلب', 'وصلت تفاصيل متجرك وفواتيره إلى فريق RVIOS.'),
                    ('حوّل المبلغ وأرسل الإيصال', 'على واتساب، إلى أحد حسابات الدفع.'),
                    ('يتفعّل متجرك', 'الباقة والقالب يعملان ويظهر متجرك للعملاء.'),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              if (waNumber != null && waMessage != null) WhatsAppButton(label: 'فتح محادثة الفريق على واتساب', onPressed: () => PlatformContact.whatsapp(waNumber!, waMessage!)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PaymentMethodsScreen())),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('حسابات الدفع'),
                style: _outline,
              ),
            ] else ...[
              _Action(icon: Icons.add_photo_alternate_rounded, color: const Color(0xFF0F766E), title: 'أضف أول منتج', body: 'صورة وسعر ووصف — يظهر في متجرك فورًا.', onTap: () {
                Navigator.of(context).popUntil((r) => r.isFirst);
                GoRouter.of(context).go(StoreRoutes.products);
              }),
              _Action(icon: Icons.brush_rounded, color: Rv.red, title: 'صمّم متجرك', body: 'الشعار والغلاف والألوان والنصوص — بمعاينة حية.', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DesignStudioScreen()))),
              _Action(icon: Icons.ios_share_rounded, color: const Color(0xFF2F6FB3), title: 'شارك الرابط', body: 'في حالتك على واتساب وإنستغرام والمجموعات.', onTap: () => SharePlus.instance.share(ShareParams(text: '🛍️ تسوّق من متجري «$name»:\n$_url'))),
              _Action(icon: Icons.open_in_new_rounded, color: const Color(0xFF7C3AED), title: 'افتح متجرك', body: 'شاهده كما يراه عميلك.', onTap: () => launchUrl(Uri.parse(_url), mode: LaunchMode.externalApplication)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: home,
              style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: const Text('إلى لوحة متجري', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      ]),
    );
  }
}

final _outline = OutlinedButton.styleFrom(minimumSize: const Size(0, 52), foregroundColor: Rv.red, side: BorderSide(color: Rv.red.withValues(alpha: .35)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)));

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.color, required this.title, required this.body, required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RvCard(
        onTap: onTap,
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: p.ink, fontSize: 15)),
              Text(body, style: TextStyle(color: p.inkMuted, fontSize: 12.5)),
            ]),
          ),
          Icon(Icons.chevron_left_rounded, color: p.inkFaint),
        ]),
      ),
    );
  }
}
