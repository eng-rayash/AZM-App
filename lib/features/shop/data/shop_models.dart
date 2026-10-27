/// AZM — نماذج منصة المتاجر على العميل
///
/// مشتقّة من العقد الفعلي لا من تخمين: `storeView` في
/// `api/src/modules/shop/stores/stores.service.ts`، و`shape` في
/// `catalog.service.ts`، و`view` في `orders.service.ts`.
///
/// ## قاعدتان تحكمان كل نموذج هنا
///
/// **١. الأرقام عقد مشترك.** حالة الطلب والدفع والمتجر أعداد لا نصوص،
/// وهي نفس الأعداد في `shop.constants.ts`. التسميات العربية تُشتقّ
/// منها على العميل بدل أن تُنقل عبر الشبكة — نصّ مُترجَم في الحمولة
/// يعني أن تغيير كلمة يحتاج نشر خادم.
///
/// **٢. الفكّ متسامح لا صارم.** حقل يضيفه الخادم غدًا لا يجوز أن
/// يُفشل شاشة اليوم، وحقل يغيب لا يجوز أن يرمي. لكن التسامح له حدّ:
/// `id` و`slug` إلزاميان — صفّ بلا هوية لا يُستعمل في شيء، وإخفاء
/// غيابه يؤجّل العطب إلى موضع أبعد.
library;

// ─────────────────────────────────────────────
// المتجر
// ─────────────────────────────────────────────

/// متجر كما تراه لوحة التاجر.
///
/// لاحظ الأزواج `theme`/`savedTheme` و`template`/`savedTemplate`
/// و`customDomain`/`savedCustomDomain`: الأول **الفعّال** حسب الباقة،
/// والثاني **المحفوظ**. متجر هبط من «برو» تبقى قيمه محفوظة وتعود
/// لحظة الترقية — إخفاء لا حذف. الواجهة تعرض الفعّال وتستعمل المحفوظ
/// لتقول «يعود بالترقية».
class ShopStore {
  const ShopStore({
    required this.id,
    required this.slug,
    required this.name,
    required this.sector,
    required this.plan,
    required this.status,
    required this.verified,
    required this.country,
    required this.currency,
    this.tagline = '',
    this.about = '',
    this.city = '',
    this.address = '',
    this.whatsapp = '',
    this.hours = '',
    this.logo = '',
    this.banner = '',
    this.showcase = '',
    this.color = '#9E2226',
    this.colorDeep = '#6E1519',
    this.theme = 'signature',
    this.savedTheme = 'signature',
    this.layout = 'signature',
    this.savedLayout = 'signature',
    this.template = 'essential',
    this.savedTemplate = 'essential',
    this.ownedTemplates = const [],
    this.customDomain,
    this.savedCustomDomain,
    this.deliveryFee = 0,
    this.deliveryFreeOver = 0,
    this.deliveryNote = '',
    this.payMethods = const ['cod'],
    this.payNote = '',
    this.createdAt,
  });

  factory ShopStore.fromJson(Map<String, dynamic> json) => ShopStore(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: _str(json['name']),
        sector: _str(json['sector'], 'other'),
        plan: _str(json['plan'], 'basic'),
        status: _int(json['status']),
        verified: json['verified'] == true,
        country: _str(json['country'], 'YE'),
        currency: _str(json['currency']),
        tagline: _str(json['tagline']),
        about: _str(json['about']),
        city: _str(json['city']),
        address: _str(json['address']),
        whatsapp: _str(json['whatsapp']),
        hours: _str(json['hours']),
        logo: _str(json['logo']),
        banner: _str(json['banner']),
        showcase: _str(json['showcase']),
        color: _str(json['color'], '#9E2226'),
        colorDeep: _str(json['colorDeep'], '#6E1519'),
        theme: _str(json['theme'], 'signature'),
        savedTheme: _str(json['savedTheme'], 'signature'),
        layout: _str(json['layout'], 'signature'),
        savedLayout: _str(json['savedLayout'], 'signature'),
        template: _str(json['template'], 'essential'),
        savedTemplate: _str(json['savedTemplate'], 'essential'),
        ownedTemplates: _strList(json['ownedTemplates']),
        customDomain: json['customDomain'] as String?,
        savedCustomDomain: json['savedCustomDomain'] as String?,
        deliveryFee: _int(json['deliveryFee']),
        deliveryFreeOver: _int(json['deliveryFreeOver']),
        deliveryNote: _str(json['deliveryNote']),
        // الخادم يخزّنها نصًّا مفصولًا بفواصل لا قائمة
        payMethods: _csv(json['payMethods'], fallback: const ['cod']),
        payNote: _str(json['payNote']),
        createdAt: _date(json['createdAt']),
      );

  final String id;

  /// رابط المتجر العام — فريد عبر كل الشركات.
  final String slug;

  final String name;
  final String sector;

  /// `basic` · `plus` · `pro` — كما يعيدها الخادم.
  final String plan;

  /// ٠ نشط · ١ موقوف. انظر [isSuspended].
  final int status;

  final bool verified;

  /// ISO حرفان — العملة تُشتقّ منها على الخادم ولا تُخزَّن.
  final String country;

  /// رمز العملة كما اشتقّه الخادم.
  final String currency;

  final String tagline;
  final String about;
  final String city;
  final String address;
  final String whatsapp;
  final String hours;

  final String logo;
  final String banner;
  final String showcase;
  final String color;
  final String colorDeep;

  /// السكِن الفعّال — يعود إلى «التوقيع» لمن دون «برو».
  final String theme;

  /// السكِن المحفوظ — يعود حين تعود الباقة.
  final String savedTheme;

  final String layout;
  final String savedLayout;

  /// قالب واجهة المتجر الفعّال.
  final String template;
  final String savedTemplate;

  /// القوالب المدفوعة المملوكة — يبدّل بينها بلا دفع جديد.
  final List<String> ownedTemplates;

  /// النطاق الخاص الفعّال — `null` للباقة المجانية.
  final String? customDomain;

  /// النطاق المحفوظ — يعود بعودة الباقة.
  final String? savedCustomDomain;

  final int deliveryFee;
  final int deliveryFreeOver;
  final String deliveryNote;

  /// `cod` · `wallet` · `bank`. الـ`cod` لا تُنزع على الخادم.
  final List<String> payMethods;
  final String payNote;

  final DateTime? createdAt;

  bool get isSuspended => status == 1;

  /// هل القيمة المحفوظة أعلى من الفعّالة؟ أي: هل تخفي الباقةُ شيئًا؟
  ///
  /// الواجهة تستعملها لتقول «يعود بالترقية» بدل أن تعرض اختيارًا
  /// محفوظًا كأنه مطبَّق — وهو ما يجعل التاجر يظنّ متجره يبدو بشكل
  /// لا يراه زوّاره.
  bool get hasHiddenTheme => savedTheme != theme;
  bool get hasHiddenTemplate => savedTemplate != template;
  bool get hasHiddenDomain =>
      (savedCustomDomain ?? '').isNotEmpty && customDomain == null;

  String get planLabel => switch (plan) {
        'pro' => 'برو',
        'plus' => 'بلس',
        _ => 'مجانية',
      };
}

/// حصّة المتاجر في باقة الشركة.
class StoreSlots {
  const StoreSlots({
    required this.owned,
    required this.slots,
    required this.free,
    this.max,
  });

  factory StoreSlots.fromJson(Map<String, dynamic> json) => StoreSlots(
        owned: _int(json['owned']),
        slots: _int(json['slots']),
        free: _int(json['free']),
        max: json['max'] as int?,
      );

  final int owned;
  final int slots;
  final int free;

  /// `null` = غير محدود.
  final int? max;

  bool get canAddStore => free > 0;
}

/// ردّ `GET /shop/stores`.
class StoreList {
  const StoreList({required this.stores, required this.slots});

  factory StoreList.fromJson(Map<String, dynamic> json) => StoreList(
        stores: _list(json['stores'], ShopStore.fromJson),
        slots: StoreSlots.fromJson(
          (json['slots'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );

  final List<ShopStore> stores;
  final StoreSlots slots;
}

// ─────────────────────────────────────────────
// الكتالوج
// ─────────────────────────────────────────────

class ShopCategory {
  const ShopCategory({required this.id, required this.name, this.sort = 0});

  factory ShopCategory.fromJson(Map<String, dynamic> json) => ShopCategory(
        id: json['id'] as String,
        name: _str(json['name']),
        sort: _int(json['sort']),
      );

  final String id;
  final String name;
  final int sort;
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.qty,
    this.price,
    this.sort = 0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json['id'] as String,
        label: _str(json['label'] ?? json['opt1'] ?? json['name']),
        qty: _int(json['qty']),
        price: json['price'] as int?,
        sort: _int(json['sort']),
      );

  final String id;
  final String label;
  final int qty;

  /// `null` = يتبع سعر المنتج.
  final int? price;
  final int sort;
}

class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    required this.live,
    this.categoryId,
    this.categoryName = '',
    this.summary = '',
    this.description = '',
    this.brand = '',
    this.oldPrice,
    this.lowStock = 0,
    this.image = '',
    this.images = const [],
    this.hasVariants = false,
    this.variants = const [],
    this.sort = 0,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) => ShopProduct(
        id: json['id'] as String,
        name: _str(json['name']),
        price: _int(json['price']),
        qty: _int(json['qty']),
        live: json['live'] != false,
        categoryId: json['categoryId'] as String?,
        categoryName: _str(json['categoryName']),
        summary: _str(json['summary']),
        description: _str(json['description']),
        brand: _str(json['brand']),
        oldPrice: json['oldPrice'] as int?,
        lowStock: _int(json['lowStock']),
        image: _str(json['image']),
        images: _strList(json['images']),
        hasVariants: json['hasVariants'] == true,
        variants: _list(json['variants'], ProductVariant.fromJson),
        sort: _int(json['sort']),
      );

  final String id;
  final String name;

  /// بأصغر وحدة للعملة — عدد صحيح لا كسر عائم.
  final int price;

  /// مصدر الحقيقة حين [hasVariants] خطأ، ومجموع مخزَّن حين صحّ.
  final int qty;

  final bool live;
  final String? categoryId;
  final String categoryName;
  final String summary;
  final String description;
  final String brand;
  final int? oldPrice;
  final int lowStock;
  final String image;
  final List<String> images;
  final bool hasVariants;
  final List<ProductVariant> variants;
  final int sort;

  bool get isLowStock => lowStock > 0 && qty <= lowStock;
  bool get isOutOfStock => qty <= 0;
  bool get hasDiscount => oldPrice != null && oldPrice! > price;
}

/// سعة الكتالوج في باقة المتجر — تُفرض على الخادم وتُعرض هنا.
class CatalogCapacity {
  const CatalogCapacity({
    required this.used,
    required this.canAdd,
    this.max,
    this.imagesPerProduct = 1,
    this.variantsPerProduct,
  });

  factory CatalogCapacity.fromJson(Map<String, dynamic> json) =>
      CatalogCapacity(
        used: _int(json['used']),
        canAdd: json['canAdd'] != false,
        max: json['max'] as int?,
        imagesPerProduct: _int(json['imagesPerProduct'], 1),
        variantsPerProduct: json['variantsPerProduct'] as int?,
      );

  final int used;
  final bool canAdd;

  /// `null` = غير محدود.
  final int? max;
  final int imagesPerProduct;
  final int? variantsPerProduct;
}

class ProductList {
  const ProductList({required this.products, required this.capacity});

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
        products: _list(json['products'], ShopProduct.fromJson),
        capacity: CatalogCapacity.fromJson(
          (json['capacity'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );

  final List<ShopProduct> products;
  final CatalogCapacity capacity;
}

// ─────────────────────────────────────────────
// الطلبات
// ─────────────────────────────────────────────

/// حالة الطلب — الأرقام نفسها في `shop.constants.ts`.
enum OrderStatus {
  wait(0, 'قيد التأكيد'),
  confirmed(1, 'مؤكد'),
  done(2, 'مكتمل'),
  off(3, 'ملغى');

  const OrderStatus(this.value, this.label);
  final int value;
  final String label;

  /// `orElse` إلزامي: حالة يضيفها الخادم غدًا لا يجوز أن ترمي في
  /// شاشة اليوم. هذا بالضبط ما أعطب ستّة تعدادات في هذا المشروع.
  static OrderStatus fromValue(int v) =>
      OrderStatus.values.firstWhere((e) => e.value == v, orElse: () => wait);
}

/// حالة الدفع — الأرقام نفسها في `shop.constants.ts`.
enum PayStatus {
  onDelivery(0, 'عند الاستلام'),
  awaitingTransfer(1, 'بانتظار التحويل'),
  proofUnderReview(2, 'إيصال للمراجعة'),
  paid(3, 'مدفوع');

  const PayStatus(this.value, this.label);
  final int value;
  final String label;

  static PayStatus fromValue(int v) => PayStatus.values
      .firstWhere((e) => e.value == v, orElse: () => onDelivery);
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    this.variant = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as String,
        name: _str(json['name']),
        price: _int(json['price']),
        qty: _int(json['qty']),
        variant: _str(json['variant']),
      );

  final String id;
  final String name;
  final int price;
  final int qty;

  /// التسمية وقت الطلب — تبقى للسجلّ ولو حُذف الخيار.
  final String variant;

  int get lineTotal => price * qty;
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.ref,
    required this.status,
    required this.payStatus,
    required this.subtotal,
    required this.total,
    this.payMethod = 'cod',
    this.payProof = '',
    this.custName = '',
    this.custPhone = '',
    this.custAddress = '',
    this.zoneName = '',
    this.note = '',
    this.deliveryFee = 0,
    this.items = const [],
    this.wa = '',
    this.createdAt,
  });

  factory ShopOrder.fromJson(Map<String, dynamic> json) => ShopOrder(
        id: json['id'] as String,
        ref: _str(json['ref']),
        status: OrderStatus.fromValue(_int(json['status'])),
        payStatus: PayStatus.fromValue(_int(json['payStatus'])),
        subtotal: _int(json['subtotal']),
        total: _int(json['total']),
        payMethod: _str(json['payMethod'], 'cod'),
        payProof: _str(json['payProof']),
        custName: _str(json['custName']),
        custPhone: _str(json['custPhone']),
        custAddress: _str(json['custAddress']),
        zoneName: _str(json['zoneName']),
        note: _str(json['note']),
        deliveryFee: _int(json['deliveryFee']),
        items: _list(json['items'], OrderItem.fromJson),
        wa: _str(json['wa']),
        createdAt: _date(json['createdAt']),
      );

  final String id;

  /// الرقم المرجعي الذي يقرؤه العميل (RS-XXXXX).
  final String ref;

  final OrderStatus status;
  final PayStatus payStatus;
  final int subtotal;
  final int total;
  final String payMethod;

  /// رابط إيصال التحويل حين يرفعه العميل.
  final String payProof;

  final String custName;
  final String custPhone;
  final String custAddress;
  final String zoneName;
  final String note;
  final int deliveryFee;
  final List<OrderItem> items;

  /// رابط واتساب جاهز برسالة الطلب — يبنيه الخادم.
  ///
  /// يأتي من الخادم لا يُبنى هنا: نصّ الرسالة في `order-message.ts`،
  /// وبناؤه مرّتين يعني نسختين تتباعدان.
  final String wa;

  final DateTime? createdAt;

  bool get hasProofToReview => payStatus == PayStatus.proofUnderReview;
}

class OrderPage {
  const OrderPage({
    required this.orders,
    required this.page,
    required this.pages,
    required this.total,
    required this.counts,
    this.perPage = 20,
  });

  factory OrderPage.fromJson(Map<String, dynamic> json) => OrderPage(
        orders: _list(json['orders'], ShopOrder.fromJson),
        page: _int(json['page'], 1),
        pages: _int(json['pages'], 1),
        total: _int(json['total']),
        perPage: _int(json['perPage'], 20),
        counts: _counts(json['counts']),
      );

  final List<ShopOrder> orders;
  final int page;
  final int pages;
  final int total;
  final int perPage;

  /// عدد الطلبات بكل حالة — للشارات على التبويبات.
  final Map<OrderStatus, int> counts;

  int countOf(OrderStatus s) => counts[s] ?? 0;
}

// ─────────────────────────────────────────────
// النظرة العامة
// ─────────────────────────────────────────────

class StoreKpis {
  const StoreKpis({
    required this.pending,
    required this.visits,
    required this.products,
    required this.confirmed,
  });

  factory StoreKpis.fromJson(Map<String, dynamic> json) => StoreKpis(
        pending: _int(json['pending']),
        visits: _int(json['visits']),
        products: _int(json['products']),
        confirmed: _int(json['confirmed']),
      );

  /// طلبات قيد التأكيد — ما يحتاج انتباه التاجر الآن.
  final int pending;

  /// زوّار سبعة أيام.
  final int visits;

  /// منتجات معروضة (live).
  final int products;

  /// مبيعات الشهر بأصغر وحدة للعملة.
  final int confirmed;
}

class DayPoint {
  const DayPoint({required this.day, required this.visits, required this.orders});

  factory DayPoint.fromJson(Map<String, dynamic> json) => DayPoint(
        day: _str(json['day']),
        visits: _int(json['visits']),
        orders: _int(json['orders']),
      );

  /// `YYYY-MM-DD`.
  final String day;
  final int visits;
  final int orders;
}

class StoreCapacity {
  const StoreCapacity({
    required this.used,
    required this.pct,
    required this.plan,
    this.max,
  });

  factory StoreCapacity.fromJson(Map<String, dynamic> json) => StoreCapacity(
        used: _int(json['used']),
        pct: _int(json['pct']),
        plan: _str(json['plan'], 'basic'),
        max: json['max'] as int?,
      );

  final int used;
  final int pct;
  final String plan;

  /// `null` = غير محدود.
  final int? max;

  bool get isUnlimited => max == null;
}

class StoreOverview {
  const StoreOverview({
    required this.kpis,
    required this.chart,
    required this.capacity,
    this.recent = const [],
    this.lowStock = const [],
  });

  factory StoreOverview.fromJson(Map<String, dynamic> json) => StoreOverview(
        kpis: StoreKpis.fromJson(
          (json['kpis'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        chart: _list(json['chart'], DayPoint.fromJson),
        capacity: StoreCapacity.fromJson(
          (json['capacity'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        recent: _list(json['recent'], ShopOrder.fromJson),
        lowStock: _list(json['lowStock'], ShopProduct.fromJson),
      );

  final StoreKpis kpis;

  /// سبعة أيام من الزيارات والطلبات.
  final List<DayPoint> chart;

  final StoreCapacity capacity;
  final List<ShopOrder> recent;
  final List<ShopProduct> lowStock;
}

/// نتيجة فحص توفّر رابط المتجر.
class SlugCheck {
  const SlugCheck({
    required this.slug,
    required this.ok,
    required this.reason,
    this.suggestion,
  });

  factory SlugCheck.fromJson(Map<String, dynamic> json) => SlugCheck(
        slug: _str(json['slug']),
        ok: json['ok'] == true,
        reason: _str(json['reason']),
        suggestion: json['suggestion'] as String?,
      );

  final String slug;
  final bool ok;

  /// سبب الرفض بالعربية كما صاغه الخادم.
  final String reason;

  /// بديل مقترَح حين يكون الرابط محجوزًا.
  final String? suggestion;
}

// ─────────────────────────────────────────────
// فكّ متسامح
// ─────────────────────────────────────────────

String _str(dynamic v, [String fallback = '']) =>
    v is String ? v : (v == null ? fallback : v.toString());

int _int(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

DateTime? _date(dynamic v) =>
    v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

List<String> _strList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : const [];

/// نصّ مفصول بفواصل → قائمة. يقبل القائمة أيضًا.
///
/// `payMethods` يخزّنها الخادم نصًّا (`cod,wallet`) ويعيدها كذلك.
/// التعامل مع الشكلين يمنع شاشة فارغة لو تغيّر التمثيل.
List<String> _csv(dynamic v, {required List<String> fallback}) {
  if (v is List) return v.map((e) => e.toString()).toList();
  if (v is String && v.isNotEmpty) {
    final parts =
        v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? fallback : parts;
  }
  return fallback;
}

List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) decode) {
  if (v is! List) return const [];
  return v
      .whereType<Map>()
      .map((e) => decode(e.cast<String, dynamic>()))
      .toList();
}

/// `{"0": 3, "1": 0, …}` → خريطة بالتعداد.
Map<OrderStatus, int> _counts(dynamic v) {
  if (v is! Map) return const {};
  final out = <OrderStatus, int>{};
  v.forEach((key, value) {
    final n = int.tryParse(key.toString());
    if (n != null) out[OrderStatus.fromValue(n)] = _int(value);
  });
  return out;
}
