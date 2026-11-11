import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/domain/notification_service.dart';
import '../shop/data/shop_models.dart';
import '../shop/providers/shop_providers.dart';
import 'azm_push.dart';

/// يراقب طلبات متاجر الشركة الجديدة ويُظهر إشعارًا على الهاتف لكل طلب لم
/// يره التاجر — سرعة الرد تصنع البيع في متجر يبيع عبر واتساب.
///
/// يسأل كل دقيقتين وهو يعمل. الإشعار والتطبيق مغلق يأتي عبر Firebase حين
/// يُضبط مشروعه (الخادم يرسل لأجهزة الشركة المسجّلة في `/notify/devices`).
class OrderWatcher {
  OrderWatcher(this._ref);
  final Ref _ref;
  Timer? _timer;
  bool _busy = false;

  static const _seenPrefix = 'azm_seen_orders_';

  void start() {
    if (_timer != null) return;
    unawaited(_tick());
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => _tick());
  }

  /// إشعار دفع وصل والتطبيق مفتوح — اسأل الآن بدل انتظار الدورة
  Future<void> checkNow() => _tick();

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    if (_busy) return;
    _busy = true;
    try {
      final api = _ref.read(shopApiProvider);
      final list = await api.listStores();
      final prefs = await SharedPreferences.getInstance();
      for (final store in list.stores) {
        final page = await api.listOrders(store.id, status: OrderStatus.wait);
        final key = '$_seenPrefix${store.id}';
        final seen = prefs.getStringList(key);
        final ids = page.orders.map((o) => o.id).toList();
        // أول مرة: نعدّ الموجود مقروءًا كي لا تنهال إشعارات الطلبات القديمة
        // في الخلفية مع إشعارات الدفع: النظام أظهر الطلب من FCM — لا نكرّره
        final background = WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
        if (seen != null && !(background && _ref.read(azmPushProvider).active)) {
          for (final o in page.orders.where((o) => !seen.contains(o.id))) {
            await _ref.read(notificationServiceProvider).showNotification(
                  id: o.id.hashCode,
                  title: 'طلب جديد ${o.ref} — ${store.name}',
                  body: '${o.custName.isEmpty ? 'عميل' : o.custName} · ${o.total.toStringAsFixed(0)}',
                );
          }
        }
        await prefs.setStringList(key, {...?seen, ...ids}.take(300).toList());
      }
    } catch (e) {
      debugPrint('OrderWatcher: $e');
    } finally {
      _busy = false;
    }
  }
}

final orderWatcherProvider = Provider<OrderWatcher>((ref) {
  final w = OrderWatcher(ref);
  ref.onDispose(w.stop);
  return w;
});
