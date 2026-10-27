import '../../../core/network/api_client.dart';
import 'shop_models.dart';

/// AZM — منصة المتاجر: طبقة النداء
///
/// تغلّف مسارات `/shop/*` على الخادم. كل دالة هنا تقابل مسارًا واحدًا،
/// والمسارات مأخوذة من المتحكّمات لا من الذاكرة:
/// `stores.controller.ts` · `catalog.controller.ts` ·
/// `orders.controller.ts` · `analytics.controller.ts`.
///
/// ## ما لا تفعله هذه الطبقة
///
/// **لا تفرض حدود الباقة.** السعة تأتي في الردّ (`capacity`, `slots`)
/// لتُعرض، والفرض على الخادم في `ShopStoreAccessService`. فحص الحدّ
/// هنا فقط يعني أن من يتجاوز العميل يتجاوز الحدّ.
///
/// **لا تخزّن شيئًا.** الحالة في المزوّدات، والذاكرة المؤقّتة في طبقة
/// أعلى. خزانة هنا تعني نسختين من الحقيقة.
///
/// **لا تعيد المحاولة.** `ApiClient` لا يعيد، ولسبب: زرّ يضغطه التاجر
/// لا يجوز أن يُنشئ طلبين.
class ShopApi {
  ShopApi(this._client);

  final ApiClient _client;

  // ─────────────────────────────────────────────
  // المتاجر
  // ─────────────────────────────────────────────

  /// متاجر الشركة مع حصّتها في الباقة.
  Future<StoreList> listStores() => _client.get(
        '/shop/stores',
        decode: (json) => StoreList.fromJson(json as Map<String, dynamic>),
      );

  /// متجر واحد.
  Future<ShopStore> getStore(String storeId) => _client.get(
        '/shop/stores/$storeId',
        decode: (json) =>
            ShopStore.fromJson(_nested(json, 'store')),
      );

  /// هل الرابط متاح؟
  ///
  /// يُستدعى قبل الإنشاء لا بعده: الخادم يرفض المحجوز بـ٤٠٩، والفحص
  /// المسبق يعطي بديلًا مقترَحًا بدل رسالة رفض بعد تعبئة النموذج.
  ///
  /// المعامل `q` لا `slug` — والفرق لا يُخطئ بصوت: الخادم يقرأ معاملًا
  /// غائبًا فراغًا ويردّ «اكتب اسم متجرك» بحالة ٢٠٠. فيظهر لكل رابط
  /// أنه غير صالح، ويبدو العطب في المستخدم لا في الطلب.
  ///
  /// [exceptStoreId] يُستثنى من الفحص — لازم عند تعديل متجر قائم كي
  /// لا يُعلن رابطه الحالي محجوزًا من نفسه.
  Future<SlugCheck> checkSlug(String query, {String? exceptStoreId}) =>
      _client.get(
        '/shop/stores/slug/check',
        query: {'q': query, 'except': ?exceptStoreId},
        decode: (json) => SlugCheck.fromJson(json as Map<String, dynamic>),
      );

  /// ينشئ متجرًا.
  ///
  /// [slug] اختياري — الخادم يشتقّه من الاسم إن غاب. و[whatsapp]
  /// إلزامي لأنه قناة الطلب: متجر بلا واتساب يستقبل طلبات لا تصل
  /// صاحبها.
  Future<ShopStore> createStore({
    required String name,
    required String whatsapp,
    String? slug,
    String? sector,
    String? country,
    String? city,
    String? tagline,
    String? color,
    String? colorDeep,
  }) =>
      _client.post(
        '/shop/stores',
        body: {
          'name': name.trim(),
          'whatsapp': whatsapp.trim(),
          'slug': ?slug,
          'sector': ?sector,
          'country': ?country,
          'city': ?city,
          'tagline': ?tagline,
          'color': ?color,
          'colorDeep': ?colorDeep,
        },
        decode: (json) => ShopStore.fromJson(_nested(json, 'store')),
      );

  /// يعدّل متجرًا — الحقول المُمرَّرة فقط.
  ///
  /// [patch] خريطة لا كائنًا بحقول اختيارية: `UpdateStoreDto` على
  /// الخادم يحمل نحو خمسة وعشرين حقلًا، وتكرارها هنا يعني موضعين
  /// يتباعدان. الخادم يرفض أي حقل غير معلَن بـ`forbidNonWhitelisted`،
  /// فالخريطة الحرّة لا تفتح بابًا.
  Future<ShopStore> updateStore(String storeId, Map<String, Object?> patch) =>
      _client.patch(
        '/shop/stores/$storeId',
        body: patch,
        decode: (json) => ShopStore.fromJson(_nested(json, 'store')),
      );

  /// يحذف متجرًا.
  ///
  /// ⚠ عملية مدمِّرة: تسحب معها الكتالوج والطلبات بـ`onDelete: Cascade`.
  /// الواجهة تطلب تأكيدًا صريحًا قبلها — ولا تكتفي بزرّ.
  Future<void> deleteStore(String storeId) =>
      _client.delete<dynamic>('/shop/stores/$storeId');

  // ─────────────────────────────────────────────
  // الكتالوج
  // ─────────────────────────────────────────────

  Future<List<ShopCategory>> listCategories(String storeId) => _client.get(
        '/shop/stores/$storeId/categories',
        decode: (json) => _decodeList(
          _field(json, 'categories'),
          ShopCategory.fromJson,
        ),
      );

  Future<ShopCategory> createCategory(String storeId, String name) =>
      _client.post(
        '/shop/stores/$storeId/categories',
        body: {'name': name.trim()},
        decode: (json) => ShopCategory.fromJson(_nested(json, 'category')),
      );

  Future<ShopCategory> renameCategory(
    String storeId,
    String categoryId,
    String name,
  ) =>
      _client.patch(
        '/shop/stores/$storeId/categories/$categoryId',
        body: {'name': name.trim()},
        decode: (json) => ShopCategory.fromJson(_nested(json, 'category')),
      );

  Future<void> deleteCategory(String storeId, String categoryId) =>
      _client.delete<dynamic>('/shop/stores/$storeId/categories/$categoryId');

  /// منتجات المتجر مع سعة الكتالوج.
  Future<ProductList> listProducts(String storeId) => _client.get(
        '/shop/stores/$storeId/products',
        decode: (json) => ProductList.fromJson(json as Map<String, dynamic>),
      );

  Future<ShopProduct> getProduct(String storeId, String productId) =>
      _client.get(
        '/shop/stores/$storeId/products/$productId',
        decode: (json) => ShopProduct.fromJson(_nested(json, 'product')),
      );

  /// ينشئ منتجًا. انظر [updateStore] لسبب تمرير خريطة.
  Future<ShopProduct> createProduct(
    String storeId,
    Map<String, Object?> data,
  ) =>
      _client.post(
        '/shop/stores/$storeId/products',
        body: data,
        decode: (json) => ShopProduct.fromJson(_nested(json, 'product')),
      );

  Future<ShopProduct> updateProduct(
    String storeId,
    String productId,
    Map<String, Object?> patch,
  ) =>
      _client.patch(
        '/shop/stores/$storeId/products/$productId',
        body: patch,
        decode: (json) => ShopProduct.fromJson(_nested(json, 'product')),
      );

  Future<void> deleteProduct(String storeId, String productId) =>
      _client.delete<dynamic>('/shop/stores/$storeId/products/$productId');

  /// يعرض منتجًا أو يخفيه — أكثر تعديل يُجريه التاجر.
  Future<ShopProduct> setProductLive(
    String storeId,
    String productId, {
    required bool live,
  }) =>
      updateProduct(storeId, productId, {'live': live});

  // ─────────────────────────────────────────────
  // الطلبات
  // ─────────────────────────────────────────────

  /// صفحة طلبات، مُرشَّحة بالحالة اختياريًا.
  ///
  /// الترشيح والترقيم على الخادم لا هنا: متجر بألف طلب لا يُحمَّل
  /// كاملًا على الجهاز ليُرشَّح في الذاكرة.
  Future<OrderPage> listOrders(
    String storeId, {
    OrderStatus? status,
    int page = 1,
  }) =>
      _client.get(
        '/shop/stores/$storeId/orders',
        query: {
          if (status != null) 'status': '${status.value}',
          'page': '$page',
        },
        decode: (json) => OrderPage.fromJson(json as Map<String, dynamic>),
      );

  Future<ShopOrder> getOrder(String storeId, String orderId) => _client.get(
        '/shop/stores/$storeId/orders/$orderId',
        decode: (json) => ShopOrder.fromJson(_nested(json, 'order')),
      );

  /// ينقل الطلب إلى حالة تالية.
  ///
  /// الخادم يقبل ١ و٢ و٣ فقط (`@IsIn([1,2,3])`) ويفرض الانتقالات
  /// المسموحة في `ORDER_NEXT`. فالعميل لا يعرض «قيد التأكيد» كهدف،
  /// لكن الخادم هو من يرفض انتقالًا غير مشروع — لا الواجهة.
  Future<ShopOrder> advanceOrder(
    String storeId,
    String orderId,
    OrderStatus to,
  ) =>
      _client.patch(
        '/shop/stores/$storeId/orders/$orderId',
        body: {'status': to.value},
        decode: (json) => ShopOrder.fromJson(_nested(json, 'order')),
      );

  /// يؤكّد استلام تحويل أو ينقضه.
  Future<ShopOrder> setOrderPaid(
    String storeId,
    String orderId, {
    required bool paid,
  }) =>
      _client.patch(
        '/shop/stores/$storeId/orders/$orderId/payment',
        body: {'paid': paid},
        decode: (json) => ShopOrder.fromJson(_nested(json, 'order')),
      );

  // ─────────────────────────────────────────────
  // التحليلات
  // ─────────────────────────────────────────────

  /// نظرة المتجر: مؤشّرات، منحنى سبعة أيام، سعة، أحدث طلبات، ومخزون
  /// منخفض — نداء واحد لا خمسة.
  Future<StoreOverview> overview(String storeId) => _client.get(
        '/shop/stores/$storeId/overview',
        decode: (json) => StoreOverview.fromJson(json as Map<String, dynamic>),
      );

  Future<List<ShopProduct>> lowStock(String storeId) => _client.get(
        '/shop/stores/$storeId/low-stock',
        decode: (json) =>
            _decodeList(_field(json, 'products'), ShopProduct.fromJson),
      );
}

// ─────────────────────────────────────────────
// فكّ الأغلفة
// ─────────────────────────────────────────────

/// الخادم يغلّف المورد الواحد (`{store: …}`, `{product: …}`).
///
/// نقبل الشكلين: المغلَّف والمجرَّد. غلاف يُسقَط على الخادم غدًا لا
/// يجوز أن يُفرغ شاشة اليوم، والعكس كذلك.
Map<String, dynamic> _nested(dynamic json, String key) {
  if (json is! Map) {
    throw FormatException('ردّ غير متوقَّع: لا كائن JSON', json);
  }
  final inner = json[key];
  if (inner is Map) return inner.cast<String, dynamic>();
  return json.cast<String, dynamic>();
}

/// قائمة قد تأتي مغلَّفة بمفتاح أو مجرَّدة.
dynamic _field(dynamic json, String key) {
  if (json is List) return json;
  if (json is Map) return json[key] ?? json;
  return const [];
}

List<T> _decodeList<T>(dynamic v, T Function(Map<String, dynamic>) decode) {
  if (v is! List) return const [];
  return v
      .whereType<Map>()
      .map((e) => decode(e.cast<String, dynamic>()))
      .toList();
}
