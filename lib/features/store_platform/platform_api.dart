import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_providers.dart';
import 'platform_catalog.dart';

/// مسارات منصة المتاجر التي يحتاجها التطبيق — نفسها التي تستعملها لوحة RVIOS OS ومنصة الويب.
class PlatformApi {
  PlatformApi(this._c);
  final ApiClient _c;

  Future<PlatformPricing> pricing() async => PlatformPricing(await _c.get('/shop/billing/pricing', decode: _map));

  /// متجر جديد. بباقة مدفوعة يصير «طلبًا» بانتظار تفعيل الفريق ومعه فواتير الباقة والقالب.
  Future<Map<String, dynamic>> createStore({
    required String name,
    required String whatsapp,
    required String slug,
    required String color,
    required StoreTemplate template,
    required PlanId plan,
    required bool yearly,
    String? sector,
  }) =>
      _c.post('/shop/stores',
          body: {
            'name': name.trim(),
            'whatsapp': whatsapp.trim(),
            'slug': slug,
            'color': color,
            'sector': ?sector,
            if (plan.paid) ...{'plan': plan.orderCode, 'months': yearly ? 12 : 1, 'template': template.id},
          },
          decode: (j) => ((_map(j))['store'] as Map).cast<String, dynamic>());

  Future<Map<String, dynamic>> checkSlug(String q) => _c.get('/shop/stores/slug/check', query: {'q': q}, decode: _map);

  Future<Map<String, dynamic>> store(String id) => _c.get('/shop/stores/$id', decode: (j) => ((_map(j))['store'] as Map).cast<String, dynamic>());
  Future<void> update(String id, Map<String, Object?> patch) => _c.patch('/shop/stores/$id', body: patch);

  Future<Map<String, dynamic>> subscription(String storeId) => _c.get('/shop/subscriptions/$storeId', decode: _map);
  Future<List<Map<String, dynamic>>> invoices(String storeId) => _c.get('/shop/invoices', query: {'storeRef': storeId}, decode: _list);

  /// فاتورة ترقية الباقة
  Future<Map<String, dynamic>> planInvoice(String storeId, PlanId plan, {required bool yearly}) =>
      _c.post('/shop/invoices', body: {'storeRef': storeId, 'kind': 0, 'plan': plan.orderCode, 'months': yearly ? 12 : 1}, decode: _map);

  /// فاتورة شراء قالب (دفعة واحدة)
  Future<Map<String, dynamic>> templateInvoice(String storeId, String template) =>
      _c.post('/shop/invoices', body: {'storeRef': storeId, 'kind': 4, 'template': template}, decode: _map);

  Future<void> submitProof(String invoiceId, String proofKey) => _c.post('/shop/invoices/$invoiceId/proof', body: {'proofKey': proofKey});

  /// شريط الإعلان، السياسات، زر واتساب، الظهور في Google — بلا قفل الأسبوع
  Future<void> saveExtras(String storeId, Map<String, Object?> extras) => _c.put('/shop/stores/$storeId/extras', body: extras);

  static Map<String, dynamic> _map(dynamic j) => (j as Map).cast<String, dynamic>();
  static List<Map<String, dynamic>> _list(dynamic j) => [for (final e in (j as List)) (e as Map).cast<String, dynamic>()];
}

final platformApiProvider = Provider<PlatformApi>((ref) => PlatformApi(ref.watch(apiClientProvider)));

/// الأسعار وحسابات الدفع — تُجلب مرة وتبقى للجلسة
final pricingProvider = FutureProvider<PlatformPricing>((ref) => ref.watch(platformApiProvider).pricing());
