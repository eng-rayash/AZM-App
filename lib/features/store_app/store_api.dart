import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/auth_token_store.dart';
import '../../core/network/network_providers.dart';

/// مسارات وحدات المتجر الجديدة في التطبيق — نفسها التي تستعملها لوحة عزم سمارت:
/// العملاء، التقييمات، مناطق التوصيل، التحليلات، الباقة والفواتير، الفريق، الإشعارات.
/// الردود تُقرأ خرائطَ مباشرة: الشاشات تعرضها، ولا منطق عمل هنا.
class StoreDataApi {
  StoreDataApi(this._c);
  final ApiClient _c;

  String _s(String id) => '/shop/stores/$id';

  Future<Map<String, dynamic>> customers(String storeId) => _c.get('${_s(storeId)}/customers', decode: _map);
  Future<Map<String, dynamic>> reviews(String storeId, {int? status}) =>
      _c.get('${_s(storeId)}/reviews', query: {if (status != null) 'status': '$status'}, decode: _map);
  Future<void> setReview(String storeId, String id, {int? status, String? reply}) =>
      _c.patch('${_s(storeId)}/reviews/$id', body: {'status': ?status, 'reply': ?reply});

  /// الخادم يعيد `{zones, fallback}` — لا قائمة مجردة (قراءتها قائمةً كانت تُفشل الشاشة)
  Future<List<Map<String, dynamic>>> zones(String storeId) =>
      _c.get('${_s(storeId)}/zones', decode: (j) => _list(j is Map ? j['zones'] ?? const [] : j));
  Future<void> addZone(String storeId, Map<String, Object?> z) => _c.post('${_s(storeId)}/zones', body: z);
  Future<void> editZone(String storeId, String id, Map<String, Object?> z) => _c.patch('${_s(storeId)}/zones/$id', body: z);
  Future<void> removeZone(String storeId, String id) => _c.delete('${_s(storeId)}/zones/$id');

  /// طلب يدوي (هاتف، واتساب، المحل) — يعيد الطلب المُنشأ
  Future<Map<String, dynamic>> createManualOrder(String storeId, Map<String, Object?> body) =>
      _c.post('${_s(storeId)}/orders', body: body, decode: _map);

  /// أسئلة المنتجات — `{questions, counts}`
  Future<Map<String, dynamic>> questions(String storeId, {int? status}) =>
      _c.get('${_s(storeId)}/questions', query: {if (status != null) 'status': '$status'}, decode: _map);
  Future<void> answerQuestion(String storeId, String id, {String? answer, int? status}) =>
      _c.patch('${_s(storeId)}/questions/$id', body: {'answer': ?answer, 'status': ?status});
  Future<void> removeQuestion(String storeId, String id) => _c.delete('${_s(storeId)}/questions/$id');

  /// جاهزية المتجر — `{percent, done, total, next, tasks:[{key,title,hint,done,link}]}`
  Future<Map<String, dynamic>> readiness(String storeId) => _c.get('${_s(storeId)}/readiness', decode: _map);

  /// قسائم الخصم — `{coupons, limit, planName, currency}`
  Future<Map<String, dynamic>> coupons(String storeId) => _c.get('${_s(storeId)}/coupons', decode: _map);
  Future<void> addCoupon(String storeId, Map<String, Object?> c) => _c.post('${_s(storeId)}/coupons', body: c);
  Future<void> editCoupon(String storeId, String id, Map<String, Object?> c) => _c.patch('${_s(storeId)}/coupons/$id', body: c);
  Future<void> removeCoupon(String storeId, String id) => _c.delete('${_s(storeId)}/coupons/$id');

  Future<Map<String, dynamic>> analytics(String storeId, int days) =>
      _c.get('${_s(storeId)}/analytics', query: {'days': '$days'}, decode: _map);

  Future<Map<String, dynamic>> pricing() => _c.get('/shop/billing/pricing', decode: _map);
  Future<List<Map<String, dynamic>>> invoices() => _c.get('/shop/invoices', decode: _list);
  Future<Map<String, dynamic>> subscription(String storeId) => _c.get('/shop/subscriptions/$storeId', decode: _map);
  Future<Map<String, dynamic>> createInvoice(Map<String, Object?> body) => _c.post('/shop/invoices', body: body, decode: _map);
  Future<void> submitProof(String invoiceId, {required String proofKey, String? method}) =>
      _c.post('/shop/invoices/$invoiceId/proof', body: {'proofKey': proofKey, 'method': ?method});

  Future<Map<String, dynamic>> members() => _c.get('/team/members', decode: _map);
  Future<Map<String, dynamic>> notifications({bool unread = false}) =>
      _c.get('/notifications', query: {if (unread) 'unread': '1'}, decode: _map);
  Future<void> readAllNotifications() => _c.post('/notifications/read-all');
  Future<Map<String, dynamic>> context() => _c.get('/auth/context', decode: _map);

  /// رفع صورة إلى مجلد المتجر في R2 — يعيد رابطها العام (إيصال، منتج، شعار).
  Future<String> uploadImage(String storeId, List<int> bytes, String filename) async {
    final token = await AuthTokenStore().readToken();
    final req = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl$apiPrefix/uploads?storeId=$storeId'))
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    if (token != null) req.headers['authorization'] = 'Bearer $token';
    final res = await http.Response.fromStream(await req.send().timeout(const Duration(seconds: 60)));
    final j = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 300) throw Exception(j is Map && j['message'] != null ? '${j['message']}' : 'تعذّر رفع الصورة');
    return '${(j as Map)['url']}';
  }

  static Map<String, dynamic> _map(dynamic j) => (j as Map).cast<String, dynamic>();
  static List<Map<String, dynamic>> _list(dynamic j) => (j as List).map((e) => (e as Map).cast<String, dynamic>()).toList();
}

final storeDataApiProvider = Provider<StoreDataApi>((ref) => StoreDataApi(ref.watch(apiClientProvider)));

/// جاهزية المتجر — تُعاد مع سحب التحديث في الرئيسية
final storeReadinessProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, storeId) => ref.watch(storeDataApiProvider).readiness(storeId),
);
