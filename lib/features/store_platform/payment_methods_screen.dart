import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/azm_tokens.dart';
import '../store_app/kit.dart';
import 'platform_api.dart';
import 'platform_catalog.dart';
import 'platform_widgets.dart';

/// طرق دفع اشتراكات RVIOS: البنوك والمحافظ بأرقامها ورموزها، وكيف يُرسَل الإيصال.
class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key, this.whatsapp});

  /// رقم التاجر — يحدّد رقم المنصة الأقرب له على واتساب
  final String? whatsapp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    final pricing = ref.watch(pricingProvider);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, title: const Text('طرق الدفع')),
      body: pricing.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Rv.red)),
        error: (e, _) => RvEmpty(icon: Icons.wifi_off_rounded, title: 'تعذّر التحميل', body: '$e', action: 'إعادة المحاولة', onAction: () => ref.invalidate(pricingProvider)),
        data: (pr) {
          final banks = pr.accounts.where((a) => a['kind'] != 'wallet').toList();
          final wallets = pr.accounts.where((a) => a['kind'] == 'wallet').toList();
          return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
            RvHero(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 30),
                const SizedBox(height: 10),
                const Text('ادفع بالطريقة الأقرب لك', style: TextStyle(fontFamily: 'Zain', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15)),
                const SizedBox(height: 6),
                Text('حوّل قيمة الباقة أو القالب إلى أحد الحسابات، وأرسل صورة الإيصال للفريق على واتساب — يتفعّل خلال ساعات العمل.',
                    style: TextStyle(color: Colors.white.withValues(alpha: .85), height: 1.6)),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final t in ['بلا عمولة على مبيعاتك', 'دفعة واحدة للقوالب', 'ريال يمني ودولار'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(99)),
                      child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            if (banks.isNotEmpty) ...[const RvSection('البنوك'), for (final a in banks) PayAccountCard(a)],
            if (wallets.isNotEmpty) ...[const RvSection('المحافظ الإلكترونية'), for (final a in wallets) PayAccountCard(a)],
            const SizedBox(height: 8),
            RvCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('بعد التحويل', style: TextStyle(fontWeight: FontWeight.w800, color: p.ink, fontSize: 16)),
                const SizedBox(height: 12),
                const HowSteps([
                  ('صوّر الإيصال', 'أو احفظ لقطة شاشة لعملية التحويل من تطبيق البنك أو المحفظة.'),
                  ('أرسله للفريق', 'على واتساب مع اسم متجرك — أو ارفعه من «الباقة والاشتراك».'),
                  ('يتفعّل طلبك', 'نؤكد الاستلام ونفعّل الباقة أو القالب، ويصلك إشعار.'),
                ]),
                WhatsAppButton(
                  label: 'راسل الفريق على واتساب',
                  onPressed: () => PlatformContact.whatsapp(PlatformContact.forPhone(whatsapp), 'مرحبًا فريق RVIOS 👋 حوّلت قيمة اشتراكي وأرفق الإيصال:'),
                ),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}
