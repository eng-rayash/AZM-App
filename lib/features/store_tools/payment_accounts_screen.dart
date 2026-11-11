import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'store_tools_api.dart';

/// حسابات دفع اشتراك RVIOS (الكريمي بالريال والدولار، جيب، جوالي) — للتاجر
/// حين يرقّي باقته أو يشتري قالبًا. الرقم يُنسخ، ورمز المحفظة يُكبَّر للمسح.
class PaymentAccountsScreen extends StatefulWidget {
  const PaymentAccountsScreen({super.key});
  @override
  State<PaymentAccountsScreen> createState() => _PaymentAccountsScreenState();
}

class _PaymentAccountsScreenState extends State<PaymentAccountsScreen> {
  late Future<List<Map<String, dynamic>>> _load = StoreToolsApi().paymentAccounts();

  Color _color(Object? hex) {
    final h = '${hex ?? '#C1272D'}'.replaceAll('#', '');
    return Color(int.tryParse('FF$h', radix: 16) ?? 0xFFC1272D);
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, title: const Text('طرق دفع اشتراك RVIOS')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) {
            return Center(
              child: TextButton(onPressed: () => setState(() => _load = StoreToolsApi().paymentAccounts()), child: const Text('تعذّر التحميل — أعد المحاولة')),
            );
          }
          final list = snap.data!;
          return ListView(padding: const EdgeInsets.all(AzmSpace.screenGutter), children: [
            Text('حوّل المبلغ إلى أحد الحسابات واكتب رقم الفاتورة في ملاحظة التحويل، ثم أرفق الإيصال من «الباقة والفواتير».',
                style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
            const SizedBox(height: AzmSpace.lg),
            for (final a in list)
              Container(
                margin: const EdgeInsets.only(bottom: AzmSpace.md),
                padding: const EdgeInsets.all(AzmSpace.lg),
                decoration: BoxDecoration(
                  color: p.surfaceRaised,
                  borderRadius: BorderRadius.circular(18),
                  border: Border(top: BorderSide(color: _color(a['color']), width: 4)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(a['kind'] == 'wallet' ? Icons.account_balance_wallet : Icons.account_balance, color: _color(a['color'])),
                    const SizedBox(width: AzmSpace.sm),
                    Expanded(child: Text('${a['providerName']}', style: AppTypography.h4.copyWith(color: p.ink))),
                    if ('${a['currency'] ?? ''}'.isNotEmpty) Text('${a['currency']}', style: AppTypography.label.copyWith(color: _color(a['color']))),
                  ]),
                  if (a['title'] != a['providerName']) Text('${a['title']}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                  if ('${a['number'] ?? ''}'.isNotEmpty) ...[
                    const SizedBox(height: AzmSpace.md),
                    Row(children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: SelectableText('${a['number']}', style: AppTypography.h3.copyWith(color: p.ink, letterSpacing: 2)),
                        ),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: _color(a['color'])),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${a['number']}'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نُسخ الرقم')));
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('نسخ'),
                      ),
                    ]),
                  ],
                  if ('${a['holder'] ?? ''}'.isNotEmpty) Text('باسم ${a['holder']}', style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
                  if ('${a['qr'] ?? ''}'.startsWith('https://') || '${a['qr'] ?? ''}'.startsWith('/pay/')) ...[
                    const SizedBox(height: AzmSpace.md),
                    GestureDetector(
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.white,
                          child: Padding(padding: const EdgeInsets.all(16), child: Image.network(_qrUrl('${a['qr']}'))),
                        ),
                      ),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Image.network(_qrUrl('${a['qr']}'), width: 120, height: 120, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                      ),
                    ),
                  ],
                  if ('${a['note'] ?? ''}'.isNotEmpty) ...[
                    const SizedBox(height: AzmSpace.sm),
                    Text('${a['note']}', style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
                  ],
                ]),
              ),
          ]);
        },
      ),
    );
  }

  /// صور QR الثابتة (`/pay/…`) تُخدم من منصة المتاجر
  String _qrUrl(String qr) => qr.startsWith('/') ? '$storefrontUrl$qr' : qr;
}
