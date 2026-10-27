import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/shop_api.dart';
import '../data/shop_models.dart';

/// AZM — مزوّدات منصة المتاجر
///
/// ## لماذا لا شيء من هذا مُخزَّن محليًا بعد
///
/// بقية التطبيق يقرأ من Drift ويزامن. المتاجر لا تفعل: كل مزوّد هنا
/// يقرأ من الخادم مباشرة.
///
/// السبب أن بيانات المتجر **ليست بيانات التاجر وحده**. الطلب يأتي من
/// زائر على الواجهة العامّة لحظةً بلحظة، والمخزون ينقص بطلب لم يمرّ
/// بهذا الجهاز. نسخة محلية هنا تعني تاجرًا يؤكّد طلبًا نُفِد مخزونه،
/// أو يرى مخزونًا باعه غيره.
///
/// وهذا يعني أن شاشات المتاجر **تحتاج اتصالًا**، بخلاف بقية التطبيق.
/// الواجهة تقول ذلك صراحةً بدل أن تعرض فراغًا يُفهم على أنه «لا طلبات».
///
/// حين يصل محرّك المزامنة يصير المرشَّح للتخزين المحلي هو الكتالوج
/// (يملكه التاجر ويعدّله دون اتصال) لا الطلبات.
final shopApiProvider = Provider<ShopApi>((ref) {
  return ShopApi(ref.watch(apiClientProvider));
});

// ─────────────────────────────────────────────
// المتاجر
// ─────────────────────────────────────────────

/// متاجر الشركة وحصّتها.
final storeListProvider = FutureProvider<StoreList>((ref) {
  return ref.watch(shopApiProvider).listStores();
});

/// المتجر المفتوح في لوحة التاجر.
///
/// معرّف لا كائن: الكائن يتقادم بعد أي تعديل، والمعرّف لا يتقادم.
/// البيانات تُجلب بـ[storeProvider].
final activeStoreIdProvider = StateProvider<String?>((ref) => null);

/// متجر بمعرّفه.
final storeProvider =
    FutureProvider.family<ShopStore, String>((ref, storeId) {
  return ref.watch(shopApiProvider).getStore(storeId);
});

/// المتجر المفتوح، أو `null` إن لم يُفتح شيء.
final activeStoreProvider = Provider<AsyncValue<ShopStore>?>((ref) {
  final id = ref.watch(activeStoreIdProvider);
  if (id == null) return null;
  return ref.watch(storeProvider(id));
});

// ─────────────────────────────────────────────
// النظرة العامة
// ─────────────────────────────────────────────

/// نداء واحد يجيب «ماذا يحتاج انتباهي في هذا المتجر؟».
final storeOverviewProvider =
    FutureProvider.family<StoreOverview, String>((ref, storeId) {
  return ref.watch(shopApiProvider).overview(storeId);
});

// ─────────────────────────────────────────────
// الكتالوج
// ─────────────────────────────────────────────

final productsProvider =
    FutureProvider.family<ProductList, String>((ref, storeId) {
  return ref.watch(shopApiProvider).listProducts(storeId);
});

final categoriesProvider =
    FutureProvider.family<List<ShopCategory>, String>((ref, storeId) {
  return ref.watch(shopApiProvider).listCategories(storeId);
});

// ─────────────────────────────────────────────
// الطلبات
// ─────────────────────────────────────────────

/// مرشّح قائمة الطلبات — `null` يعني كل الحالات.
final orderFilterProvider = StateProvider<OrderStatus?>((ref) => null);

/// الصفحة المعروضة. تُصفَّر عند تغيير المرشّح.
final orderPageNumberProvider = StateProvider<int>((ref) {
  // الاستماع لا القراءة: تغيير المرشّح يعيد بناء هذا المزوّد فيعود
  // إلى ١. بدونه ينتقل المستخدم من صفحة ٥ في «مكتمل» إلى صفحة ٥ في
  // «قيد التأكيد» التي قد لا توجد، فيرى فراغًا.
  ref.watch(orderFilterProvider);
  return 1;
});

/// صفحة الطلبات بحسب المرشّح والصفحة الحاليين.
final orderPageProvider =
    FutureProvider.family<OrderPage, String>((ref, storeId) {
  final status = ref.watch(orderFilterProvider);
  final page = ref.watch(orderPageNumberProvider);
  return ref.watch(shopApiProvider).listOrders(
        storeId,
        status: status,
        page: page,
      );
});

// ─────────────────────────────────────────────
// الإجراءات
// ─────────────────────────────────────────────

/// إجراءات تُغيّر حالة على الخادم ثم تُبطل ما تأثّر.
///
/// صنف لا دوال حرّة: كل إجراء يحتاج إبطال أكثر من مزوّد، وترك ذلك
/// للمستدعي يعني شاشة تعرض بيانات قديمة بعد تعديل ناجح — وهو عطب
/// يبدو كأن الزرّ لم يعمل.
class ShopActions {
  const ShopActions(this._ref);

  final Ref _ref;

  ShopApi get _api => _ref.read(shopApiProvider);

  // ── المتاجر ──

  Future<ShopStore> createStore({
    required String name,
    required String whatsapp,
    String? slug,
    String? sector,
    String? country,
    String? city,
  }) async {
    final store = await _api.createStore(
      name: name,
      whatsapp: whatsapp,
      slug: slug,
      sector: sector,
      country: country,
      city: city,
    );
    // الحصّة تغيّرت أيضًا لا القائمة وحدها
    _ref.invalidate(storeListProvider);
    return store;
  }

  Future<ShopStore> updateStore(
    String storeId,
    Map<String, Object?> patch,
  ) async {
    final store = await _api.updateStore(storeId, patch);
    _ref.invalidate(storeProvider(storeId));
    _ref.invalidate(storeListProvider);
    return store;
  }

  /// يحذف متجرًا — مدمِّر، ويفترض تأكيدًا سبقه في الواجهة.
  Future<void> deleteStore(String storeId) async {
    await _api.deleteStore(storeId);

    // المعرّف يُصفَّر قبل الإبطال: لو بقي مضبوطًا لجلب
    // `activeStoreProvider` متجرًا محذوفًا فأظهر ٤٠٤ بدل عودة نظيفة.
    if (_ref.read(activeStoreIdProvider) == storeId) {
      _ref.read(activeStoreIdProvider.notifier).state = null;
    }
    _ref.invalidate(storeProvider(storeId));
    _ref.invalidate(storeListProvider);
  }

  // ── الكتالوج ──

  Future<ShopProduct> createProduct(
    String storeId,
    Map<String, Object?> data,
  ) async {
    final product = await _api.createProduct(storeId, data);
    _invalidateCatalog(storeId);
    return product;
  }

  Future<ShopProduct> updateProduct(
    String storeId,
    String productId,
    Map<String, Object?> patch,
  ) async {
    final product = await _api.updateProduct(storeId, productId, patch);
    _invalidateCatalog(storeId);
    return product;
  }

  Future<void> deleteProduct(String storeId, String productId) async {
    await _api.deleteProduct(storeId, productId);
    _invalidateCatalog(storeId);
  }

  Future<ShopProduct> setProductLive(
    String storeId,
    String productId, {
    required bool live,
  }) async {
    final product =
        await _api.setProductLive(storeId, productId, live: live);
    _invalidateCatalog(storeId);
    return product;
  }

  Future<ShopCategory> createCategory(String storeId, String name) async {
    final category = await _api.createCategory(storeId, name);
    _ref.invalidate(categoriesProvider(storeId));
    return category;
  }

  Future<void> deleteCategory(String storeId, String categoryId) async {
    await _api.deleteCategory(storeId, categoryId);
    _ref.invalidate(categoriesProvider(storeId));
    // المنتجات تحمل اسم التصنيف، وحذفه يصيّره فارغًا
    _ref.invalidate(productsProvider(storeId));
  }

  // ── الطلبات ──

  Future<ShopOrder> advanceOrder(
    String storeId,
    String orderId,
    OrderStatus to,
  ) async {
    final order = await _api.advanceOrder(storeId, orderId, to);
    _invalidateOrders(storeId);
    return order;
  }

  Future<ShopOrder> setOrderPaid(
    String storeId,
    String orderId, {
    required bool paid,
  }) async {
    final order = await _api.setOrderPaid(storeId, orderId, paid: paid);
    _invalidateOrders(storeId);
    return order;
  }

  // ── الإبطال ──

  /// تعديل الكتالوج يحرّك السعة والنظرة العامة أيضًا.
  void _invalidateCatalog(String storeId) {
    _ref.invalidate(productsProvider(storeId));
    _ref.invalidate(storeOverviewProvider(storeId));
  }

  /// تقدّم الطلب يحرّك عدّادات الحالات ومؤشّرات النظرة العامة.
  ///
  /// تأكيد طلب يُنقص المخزون على الخادم، فالكتالوج يُبطَل كذلك —
  /// وإلّا بقي التاجر يرى كميّة لم تعد صحيحة.
  void _invalidateOrders(String storeId) {
    _ref.invalidate(orderPageProvider(storeId));
    _ref.invalidate(storeOverviewProvider(storeId));
    _ref.invalidate(productsProvider(storeId));
  }
}

final shopActionsProvider = Provider<ShopActions>((ref) {
  return ShopActions(ref);
});
