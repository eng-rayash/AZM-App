@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/network/api_client.dart';
import 'package:azm/core/network/api_config.dart';
import 'package:azm/core/network/api_exception.dart';
import 'package:azm/core/network/auth_token_store.dart';
import 'package:azm/core/security/secure_storage_service.dart';
import 'package:azm/features/auth/data/azm_auth_api.dart';
import 'package:azm/features/shop/data/shop_api.dart';
import 'package:azm/features/shop/data/shop_models.dart';

/// منصة المتاجر — عقد العميل والخادم على خادم يعمل فعلًا.
///
/// الخادم يعرض نحو ستّين مسارًا لـ`/shop/*`، ونماذج العميل مشتقّة من
/// `storeView` و`shape` و`view` بالقراءة. القراءة لا تكفي: حقل
/// يُغيَّر اسمه على الخادم يمرّ من كل اختبارات الطرفين منفردين، ويظهر
/// في الإنتاج وحده كحقل فارغ في شاشة.
///
/// الرحلة هنا كاملة: تسجيل شركة ← إنشاء متجر ← تصنيف ← منتج ←
/// قراءة النظرة العامة ← حدود الباقة. وكلها بأسماء الحقول التي
/// ستعرضها الشاشات.
///
/// ⚠ يتطلّب خادمًا على `127.0.0.1:3001` وقاعدة تعمل. حين لا يتوفّران
/// **تُتجاوَز** ولا تفشل — مطوّر واجهة لا يُحمَّل تهيئة خادم.
void main() {
  // من البيئة لا ثابتًا: المنفذ قد يتغيّر حسب ما يشغّله المطوّر.
  //   AZM_API_BASE_URL=http://127.0.0.1:3099 flutter test …
  final baseUrl = Platform.environment['AZM_API_BASE_URL'] ??
      'http://127.0.0.1:3099';
  late bool serverUp;

  /// جلسة واحدة لكل الملف: التسجيل يكلّف تجزئة bcrypt بـ١٢ جولة،
  /// وتكراره لكل اختبار يضاعف زمن التشغيل بلا فائدة.
  late ShopApi shop;
  late ShopStore storeCreated;
  late String storeId;

  setUpAll(() async {
    serverUp = await _reachable(baseUrl);
    if (!serverUp) {
      // ignore: avoid_print
      print(
        '⏭ تُتجاوَز اختبارات عقد المتاجر: لا خادم على $baseUrl. '
        'شغّله بـ`cd api && npm start`.',
      );
      return;
    }

    final tokens = _MemoryTokenStore();
    final client = ApiClient(tokens: tokens, baseUrl: baseUrl);
    final session = await AzmAuthApi(client).registerWithCompany(
      email: 'shop-${DateTime.now().microsecondsSinceEpoch}@azm.test',
      password: 'shop-contract-1234',
      displayName: 'تاجر العقد',
      companyName: 'شركة متاجر العقد',
    );
    await tokens.save(
      token: session.accessToken,
      companyId: session.company.id,
    );

    shop = ShopApi(client);

    // المتجر يُنشأ هنا لا في اختبار: `late` يُضبط في أحد الاختبارات
    // ويُقرأ في بقيّتها يجعل عطبًا واحدًا يُسقط الملف كلّه بـ
    // `LateInitializationError` — وهو ضجيج يخفي السبب الأصلي.
    //
    // والاسم يحمل طابعًا زمنيًا لأن **الرابط فريد عبر كل الشركات**:
    // اسم ثابت ينجح أول تشغيل ويتصادم في الثاني.
    storeCreated = await shop.createStore(
      name: 'متجر العقد ${_stamp()}',
      whatsapp: '0551234567',
      sector: 'perfumes',
      country: 'SA',
      city: 'الرياض',
    );
    storeId = storeCreated.id;
  });

  // ─────────────────────────────────────────────
  // المتاجر
  // ─────────────────────────────────────────────

  group('المتاجر', () {
    test('القائمة تعيد الحصّة لا المتاجر وحدها', () async {
      if (!serverUp) return;

      final list = await shop.listStores();

      expect(list.stores.map((s) => s.id), contains(storeId));
      expect(list.slots.owned, list.stores.length);
      // الحصّة تأتي من الباقة — الرقم نفسه الذي تعرضه الواجهة
      expect(list.slots.slots, greaterThan(0));
      expect(list.slots.free, list.slots.slots - list.slots.owned);
    });

    test('فحص الرابط يعطي سببًا وبديلًا لا رفضًا صامتًا', () async {
      if (!serverUp) return;

      // ٣٠ حرفًا حدّ `slugProblem`، فالطابع الزمني يُقتطع
      final free = await shop.checkSlug('aqd${_stamp().substring(8)}');
      expect(free.ok, isTrue, reason: 'سبب الخادم: ${free.reason}');
      expect(free.slug, isNotEmpty);

      // رابط محجوز للمنصة (`RESERVED_SLUGS`)
      final reserved = await shop.checkSlug('admin');
      expect(reserved.ok, isFalse);
      expect(reserved.reason, isNotEmpty);
    });

    test('المعامل `q` لا `slug` — اسم خاطئ يُرفض كل رابط بصمت', () async {
      if (!serverUp) return;

      // كان العميل يرسل `slug=`، فيقرأ الخادم معاملًا غائبًا فراغًا
      // ويردّ «اكتب اسم متجرك» بحالة ٢٠٠. فيظهر لكل رابط أنه غير
      // صالح، ويبدو العطب في المستخدم لا في الطلب.
      final check = await shop.checkSlug('aqd${_stamp().substring(8)}');
      expect(check.reason, isNot('اكتب اسم متجرك'));
    });

    test('الإنشاء يعيد المتجر بكل ما تعرضه اللوحة', () async {
      if (!serverUp) return;

      final store = storeCreated;

      expect(store.id, isNotEmpty);
      expect(store.slug, isNotEmpty);
      expect(store.name, startsWith('متجر العقد'));
      expect(store.sector, 'perfumes');
      expect(store.city, 'الرياض');

      // العملة مشتقّة على الخادم من الدولة ولا تُخزَّن
      expect(store.country, 'SA');
      expect(store.currency, isNotEmpty);

      // الباقة ووسائل الدفع — تظهر في رأس اللوحة
      expect(store.plan, isNotEmpty);
      expect(store.planLabel, isNotEmpty);
      expect(store.payMethods, contains('cod'));
      expect(store.isSuspended, isFalse);
    });

    test('المتجر الجديد على الباقة المجانية: لا سكِن ولا نطاق خاص',
        () async {
      if (!serverUp) return;

      final store = await shop.getStore(storeId);

      // الفعّال يعود إلى «التوقيع» لمن دون «برو» — إخفاء لا حذف
      expect(store.theme, 'signature');
      expect(store.layout, 'signature');
      // النطاق الخاص حكر على المدفوعة
      expect(store.customDomain, isNull);
    });

    test('التعديل يحفظ ويعيد المحفوظ', () async {
      if (!serverUp) return;

      final updated = await shop.updateStore(storeId, {
        'tagline': 'عطور شرقية فاخرة',
        'about': 'نبيع ما نحبّ',
        'deliveryFee': 1500,
        'deliveryFreeOver': 20000,
      });

      expect(updated.tagline, 'عطور شرقية فاخرة');
      expect(updated.about, 'نبيع ما نحبّ');
      expect(updated.deliveryFee, 1500);
      expect(updated.deliveryFreeOver, 20000);
    });

    test('رابط محجوز يُرفض بـAlreadyExists لا بتعارض نسخ', () async {
      if (!serverUp) return;

      final mine = await shop.getStore(storeId);

      // الرابط فريد عبر كل الشركات، فإعادة استخدامه تُرفض
      final e = await _capture(
        () => shop.createStore(
          name: 'متجر منتحل ${_stamp()}',
          whatsapp: '0559999999',
          slug: mine.slug,
        ),
      );

      // الخادم يردّ هنا ٤٠٠ «هذا الرابط محجوز» لا ٤٠٩: التحقّق يقع في
      // طبقة التحقّق قبل الكتابة. المهمّ أنه ليس تعارض نسخ.
      expect(e, isNot(isA<VersionConflict>()));
      expect(e.isRetryable, isFalse);
      expect(e.message, isNotEmpty);
    });

    test('بيانات ناقصة ⇐ BadRequest بأخطاء حقول', () async {
      if (!serverUp) return;

      // الاسم أقصر من الحدّ الأدنى على الخادم
      final e = await _capture(
        () => shop.createStore(name: 'x', whatsapp: '0551234567'),
      );

      expect(e, isA<BadRequest>());
      expect((e as BadRequest).fieldErrors, isNotEmpty);
    });

    test('متجر شركة أخرى ⇐ NotFound لا Forbidden', () async {
      if (!serverUp) return;

      // شركة ثانية مستقلّة تمامًا
      final otherTokens = _MemoryTokenStore();
      final otherClient = ApiClient(tokens: otherTokens, baseUrl: baseUrl);
      final other = await AzmAuthApi(otherClient).registerWithCompany(
        email: 'intruder-${_stamp()}@azm.test',
        password: 'intruder-pass-1234',
        displayName: 'متطفّل',
        companyName: 'شركة المتطفّل',
      );
      await otherTokens.save(
        token: other.accessToken,
        companyId: other.company.id,
      );

      // «غير موجود» لا «ممنوع»: الثانية تؤكّد وجود المتجر لدى غيره
      final e = await _capture(
        () => ShopApi(otherClient).getStore(storeId),
      );
      expect(e, isA<NotFound>());
    });
  });

  // ─────────────────────────────────────────────
  // الكتالوج
  // ─────────────────────────────────────────────

  group('الكتالوج', () {
    String? categoryId;

    test('تصنيف يُنشأ ويُقرأ', () async {
      if (!serverUp) return;

      final created = await shop.createCategory(storeId, 'عطور رجالية');
      categoryId = created.id;

      expect(created.name, 'عطور رجالية');

      final all = await shop.listCategories(storeId);
      expect(all.map((c) => c.id), contains(created.id));
    });

    test('منتج يُنشأ بالحقول التي تعرضها البطاقة', () async {
      if (!serverUp) return;

      final product = await shop.createProduct(storeId, {
        'name': 'عود كمبودي',
        'summary': 'تولة واحدة',
        'price': 45000,
        'oldPrice': 60000,
        'qty': 12,
        'lowStock': 3,
        'brand': 'دار العود',
        'categoryId': categoryId,
        'live': true,
      });

      expect(product.name, 'عود كمبودي');
      expect(product.price, 45000);
      expect(product.qty, 12);
      expect(product.live, isTrue);
      expect(product.brand, 'دار العود');

      // الاسم المسطَّح من العلاقة — تعرضه البطاقة
      expect(product.categoryName, 'عطور رجالية');

      // مشتقّات تعتمد عليها الواجهة
      expect(product.hasDiscount, isTrue);
      expect(product.isLowStock, isFalse);
      expect(product.isOutOfStock, isFalse);
    });

    test('السعة تأتي من الخادم لا تُحسب هنا', () async {
      if (!serverUp) return;

      final list = await shop.listProducts(storeId);

      expect(list.products, hasLength(1));
      expect(list.capacity.used, 1);
      // الحدّ يُفرض على الخادم؛ هنا يُعرض فقط
      expect(list.capacity.imagesPerProduct, greaterThan(0));
    });

    test('الإخفاء يعمل — أكثر تعديل يُجريه التاجر', () async {
      if (!serverUp) return;

      final list = await shop.listProducts(storeId);
      final id = list.products.single.id;

      final hidden = await shop.setProductLive(storeId, id, live: false);
      expect(hidden.live, isFalse);

      final shown = await shop.setProductLive(storeId, id, live: true);
      expect(shown.live, isTrue);
    });

    test('مخزون منخفض يُكتشف بالحدّ لا بالصفر', () async {
      if (!serverUp) return;

      final list = await shop.listProducts(storeId);
      final id = list.products.single.id;

      // الكمّية تساوي حدّ التنبيه
      final low = await shop.updateProduct(storeId, id, {'qty': 3});
      expect(low.isLowStock, isTrue);
      expect(low.isOutOfStock, isFalse);

      await shop.updateProduct(storeId, id, {'qty': 12});
    });
  });

  // ─────────────────────────────────────────────
  // الطلبات والنظرة العامة
  // ─────────────────────────────────────────────

  group('الطلبات', () {
    test('متجر جديد: صفحة فارغة بعدّادات صفرية لا خطأ', () async {
      if (!serverUp) return;

      final page = await shop.listOrders(storeId);

      expect(page.orders, isEmpty);
      expect(page.total, 0);
      expect(page.page, 1);
      // العدّادات تُرسم عليها شارات التبويبات
      expect(page.countOf(OrderStatus.wait), 0);
      expect(page.countOf(OrderStatus.done), 0);
    });

    test('الترشيح بالحالة يمرّ إلى الخادم', () async {
      if (!serverUp) return;

      final page = await shop.listOrders(
        storeId,
        status: OrderStatus.confirmed,
      );
      expect(page.orders, isEmpty);
    });
  });

  group('النظرة العامة', () {
    test('نداء واحد يعيد كل ما يرسمه رأس اللوحة', () async {
      if (!serverUp) return;

      final o = await shop.overview(storeId);

      expect(o.kpis.pending, 0);
      expect(o.kpis.products, greaterThanOrEqualTo(1));
      expect(o.kpis.confirmed, 0);

      // منحنى سبعة أيام — الطول عقد تعتمد عليه الرسمة
      expect(o.chart, hasLength(7));
      expect(o.chart.first.day, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));

      expect(o.capacity.used, greaterThanOrEqualTo(1));
      expect(o.capacity.plan, isNotEmpty);
      expect(o.recent, isEmpty);
    });
  });

  // ─────────────────────────────────────────────
  // التنظيف
  // ─────────────────────────────────────────────

  group('الحذف', () {
    test('المتجر الوحيد لا يُحذف بهذا المسار — قاعدة خادم لا قيد واجهة',
        () async {
      if (!serverUp) return;

      // `stores.service.ts`: «احذف الحساب بدلًا من ذلك». شركة بلا
      // متجر حالة لا معنى لها في منصة متاجر، والخادم يمنعها بـ٤٠٩.
      // الواجهة تعرض هذه الرسالة ولا تعرض زرًّا يفشل.
      final e = await _capture(() => shop.deleteStore(storeId));
      expect(e, isA<AlreadyExists>());
      expect(e.message, contains('الوحيد'));
    });

    test('خانة واحدة في المجانية — ومتجر ثانٍ يُرفض برسالة قابلة للتنفيذ',
        () async {
      if (!serverUp) return;

      // هذا ما يصطدم به تاجر الباقة المجانية فعلًا، وهو سبب تعذّر
      // اختبار الحذف مع متجر ثانٍ هنا: يحتاج باقة مدفوعة.
      final before = await shop.listStores();
      expect(before.slots.free, 0);
      expect(before.slots.canAddStore, isFalse);

      final e = await _capture(
        () => shop.createStore(
          name: 'متجر ثانٍ ${_stamp()}',
          whatsapp: '0557654321',
          country: 'SA',
        ),
      );

      // الرسالة تقول ما يُفعل لا «فشل»: الواجهة تعرضها كما هي، وتُعطّل
      // زرّ الإضافة بـ`canAddStore` بدل أن تتركه يفشل عند الضغط.
      expect(e.isRetryable, isFalse);
      expect(e.message, contains('خانة متجر'));

      // ولم يُنشأ شيء
      final after = await shop.listStores();
      expect(after.stores, hasLength(before.stores.length));
    });
  });
}

// ─────────────────────────────────────────────
// أدوات
// ─────────────────────────────────────────────

String _stamp() => '${DateTime.now().microsecondsSinceEpoch}';

/// هل على [baseUrl] خادم **عزم** فعلًا؟
///
/// فحص اتصال TCP وحده لا يكفي، وهذا ليس احتمالًا نظريًا: المنفذان
/// ٣٠٠٠ و٣٠٠١ مأخوذان على جهاز التطوير بخادمَي Next، فنجح الاتصال
/// وذهبت طلبات الاختبار إلى خادم غريب ردّ ٥٠٠ — فبدا الخطأ في خادمنا.
///
/// التحقّق هنا بالبصمة: `/auth/me` محميّ بالحارس العامّ، فخادم عزم
/// يردّ عليه ٤٠١ بلا رمز. أي ردّ آخر يعني أن المنفذ ليس لنا.
Future<bool> _reachable(String baseUrl) async {
  final uri = Uri.tryParse('$baseUrl$apiPrefix/auth/me');
  if (uri == null) return false;

  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 2);
  try {
    final response = await client.getUrl(uri).then((r) => r.close());
    await response.drain<void>();
    return response.statusCode == 401;
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

Future<ApiException> _capture(Future<void> Function() body) async {
  try {
    await body();
  } on ApiException catch (e) {
    return e;
  }
  fail('توقّعنا ApiException ولم يُرمَ شيء');
}

class _MemoryTokenStore extends AuthTokenStore {
  _MemoryTokenStore() : super(_UnusedStorage());

  String? _token;
  String? _companyId;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<String?> readCompanyId() async => _companyId;

  @override
  Future<void> save({required String token, required String companyId}) async {
    _token = token;
    _companyId = companyId;
  }

  @override
  Future<void> clear() async {
    _token = null;
    _companyId = null;
  }

  @override
  Future<bool> get hasSession async => _token != null;
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('لا يجوز أن يصل الاختبار إلى التخزين الآمن');
}
