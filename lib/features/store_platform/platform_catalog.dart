import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../store_tools/store_tools_api.dart' show storefrontUrl;

part 'catalog_data.dart';

/// منصة متاجر RVIOS داخل التطبيق — القوالب والباقات والأسعار ورسالة التفعيل.
///
/// الكتالوج نفسه الذي تعرضه منصة المتاجر على الويب (`catalog_data.dart` مولَّد منه)،
/// والأسعار الفعلية من الخادم ([PlatformPricing]) لا من هنا: الفريق يغيّرها من لوحته.

/// قالب متجر: معاينته متجر عرض حقيقي على المنصة (`/s/<demo>`).
class StoreTemplate {
  const StoreTemplate({
    required this.id,
    required this.demo,
    required this.tier,
    required this.basePrice,
    required this.sector,
    required this.name,
    required this.demoStore,
    required this.tag,
    required this.desc,
    required this.feats,
    required this.palette,
  });

  final String id;
  final String demo;

  /// free · standard · signature
  final String tier;
  final int basePrice;
  final String sector;
  final String name;
  final String demoStore;
  final String tag;
  final String desc;
  final List<String> feats;
  final List<Color> palette;

  bool get isFree => tier == 'free';
  String get tierName => switch (tier) { 'signature' => 'توقيع', 'standard' => 'قياسي', _ => 'مجاني' };

  /// لقطة القالب على الجوال (٦٠٠×١٢٩٨) من منصة المتاجر
  String get shot => '$storefrontUrl/previews/$id-mob.webp';
  String get shotDesk => '$storefrontUrl/previews/$id-desk.webp';

  /// متجر العرض الحي
  String get demoUrl => '$storefrontUrl/s/$demo';

  static List<StoreTemplate> get all => _catalog;
  static StoreTemplate byId(String id) => _catalog.firstWhere((t) => t.id == id, orElse: () => _catalog.firstWhere((t) => t.id == 'essential'));
}

/// الباقات بأسماء المنصة: مجاني · احترافي · أعمال.
/// الخادم يسمّي «احترافي» plus و«أعمال» pro (أسماء قديمة باقية في القاعدة).
enum PlanId {
  free('مجاني', 'basic', null),
  pro('احترافي', 'plus', 'plus'),
  biz('أعمال', 'pro', 'pro');

  const PlanId(this.label, this.serverCode, this.orderCode);
  final String label;

  /// كما يعيدها الخادم في `store.plan`
  final String serverCode;

  /// كما يقبلها `POST /shop/stores` و`POST /shop/invoices`
  final String? orderCode;

  bool get paid => this != PlanId.free;

  static PlanId fromServer(String? code) => switch (code) { 'pro' => PlanId.biz, 'plus' => PlanId.pro, _ => PlanId.free };

  String get pitch => switch (this) {
        PlanId.free => 'لتجربة المنصة وبدء البيع اليوم',
        PlanId.pro => 'للمتاجر النشطة التي تبيع كل يوم',
        PlanId.biz => 'للشركات والعلامات التجارية',
      };

  List<String> get perks => switch (this) {
        PlanId.free => const ['القالب الأساسي بهويتك', 'رابط متجر خاص', '١٠ منتجات و٣ تصنيفات', 'سلة وطلبات محفوظة'],
        PlanId.pro => const ['٥٠٠ منتج وتصنيفات بلا حد', 'كل القوالب (المميزة دفعة واحدة)', 'ربط دومين خاص', 'كوبونات وإحصائيات', 'إزالة عبارة المنصة وشارة التوثيق'],
        PlanId.biz => const ['منتجات بلا حد', 'القوالب القياسية مجانًا، والتوقيع بخصم ٤٠٪', 'دومين خاص مجاني أول سنة', '٣ حسابات فريق ومخزون'],
      };

  IconData get icon => switch (this) { PlanId.free => Icons.rocket_launch_outlined, PlanId.pro => Icons.workspace_premium_rounded, PlanId.biz => Icons.diamond_outlined };
}

/// الأسعار كما يعلنها الخادم (`GET /shop/billing/pricing`) مع حسابات الدفع.
class PlatformPricing {
  PlatformPricing(this.raw);
  final Map<String, dynamic> raw;

  String get currency => '${raw['currency'] ?? 'USD'}';
  int get yearlyMonthsFree => (raw['yearlyMonthsFree'] as num?)?.toInt() ?? 2;

  num price(PlanId plan, {required bool yearly}) {
    if (!plan.paid) return 0;
    final p = (raw['plans'] as Map?)?[plan.name] as Map?;
    return (p?[yearly ? 'year' : 'month'] as num?) ?? 0;
  }

  /// سعر القالب الأساسي قبل خصم الباقة
  num templateBase(StoreTemplate t) {
    for (final e in (raw['templates'] as List?) ?? const []) {
      if (e is Map && e['id'] == t.id) return (e['price'] as num?) ?? t.basePrice;
    }
    return t.basePrice;
  }

  /// كلفة القالب مع الباقة — قاعدة الخادم نفسها (`templateCost`):
  /// المجاني صفر، والمدفوع يحتاج باقة مدفوعة، و«أعمال» تشمل القياسي وتخصم التوقيع ٤٠٪.
  /// `null` = لا يُتاح مع هذه الباقة.
  num? templateCost(StoreTemplate t, PlanId plan, {List<String> owned = const []}) {
    if (t.isFree || owned.contains(t.id)) return 0;
    if (plan == PlanId.free) return null;
    final base = templateBase(t);
    if (plan == PlanId.biz) return t.tier == 'standard' ? 0 : (base * .6).round();
    return base;
  }

  List<Map<String, dynamic>> get accounts =>
      [for (final a in (raw['accounts'] as List?) ?? const []) if (a is Map && a['enabled'] != false) a.cast<String, dynamic>()];
}

/// رقم المنصة على واتساب — كما في موقع المنصة: السعودية برقمها، والبقية برقم اليمن.
class PlatformContact {
  PlatformContact._();
  static const sa = '966551341301';
  static const ye = '967739008083';

  static String forPhone(String? phone, {String? country}) {
    final d = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (country == 'SA' || d.startsWith('966') || d.startsWith('05')) return sa;
    return ye;
  }

  static Future<bool> whatsapp(String number, String message) =>
      launchUrl(Uri.parse('https://wa.me/$number?text=${Uri.encodeComponent(message)}'), mode: LaunchMode.externalApplication);
}

/// رسالة الطلب التي تصل الفريق على واتساب — يكمّل بها الدفع ويفعّل المتجر.
String activationMessage({
  required String store,
  required String slug,
  required StoreTemplate template,
  required PlanId plan,
  required bool yearly,
  required num total,
  required String currency,
  String? purpose,
}) {
  final cycle = yearly ? 'سنوي' : 'شهري';
  return [
    purpose ?? 'مرحبًا فريق RVIOS 👋 أريد تفعيل متجري:',
    '🏪 المتجر: $store ($slug.rvios.com)',
    '🎨 القالب: ${template.name}',
    if (plan.paid) '⭐ الباقة: ${plan.label} · $cycle',
    '💰 الإجمالي: ${fmtMoney(total)} ${currencyLabel(currency)}',
    '',
    'أرسلت الطلب من تطبيق RVIOS، وسأرسل إيصال التحويل هنا.',
  ].join('\n');
}

String currencyLabel(String c) => switch (c) { 'USD' => r'$', 'YER' => 'ر.ي', 'SAR' => 'ر.س', _ => c };

String fmtMoney(num v) {
  final whole = v == v.roundToDouble();
  return whole ? v.round().toString() : v.toStringAsFixed(2);
}
