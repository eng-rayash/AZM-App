import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_providers.dart';
import 'order_watcher.dart';

/// إشعارات الدفع لتطبيق عزم (Firebase Cloud Messaging — مشروع rvios-tech).
///
/// رمز الجهاز يُسجَّل عند الخادم مع الشركة النشطة (`POST /notify/devices`)،
/// فيصل إشعار كل طلب جديد في متاجرها والتطبيق مغلق. والتطبيق مفتوح لا يُظهر
/// أندرويد إشعار FCM، فيسأل `OrderWatcher` فورًا ويُظهر الطلب مرة واحدة.
class AzmPush {
  AzmPush(this._ref);
  final Ref _ref;

  String? _token;
  bool _started = false;
  final _subs = <StreamSubscription<dynamic>>[];

  bool get active => _token != null;
  bool get _supported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> start() async {
    if (_started || !_supported) return;
    _started = true;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final android = FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      // القنوات بالأسماء التي يرسلها الخادم
      await android?.createNotificationChannel(const AndroidNotificationChannel('orders', 'طلبات المتجر',
          description: 'طلب جديد في أحد متاجرك', importance: Importance.max));
      await android?.createNotificationChannel(const AndroidNotificationChannel('general', 'تنبيهات عزم',
          description: 'الاشتراك والفواتير وتنبيهات المنصة', importance: Importance.high));

      final m = FirebaseMessaging.instance;
      await m.requestPermission();
      _token = await m.getToken();
      if (_token != null) await _register(_token!);
      _subs
        ..add(m.onTokenRefresh.listen((t) {
          _token = t;
          _register(t);
        }))
        ..add(FirebaseMessaging.onMessage.listen((msg) {
          if (msg.data['kind'] == 'order') _ref.read(orderWatcherProvider).checkNow();
        }));
    } catch (e) {
      // بلا Google Play Services أو بلا شبكة: يبقى المراقب الدوري يعمل
      debugPrint('AzmPush: $e');
      _started = false;
    }
  }

  Future<void> _register(String token) async {
    try {
      await _ref.read(apiClientProvider).post<dynamic>('/notify/devices', body: {
        'token': token,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      });
    } catch (e) {
      // جلسة محلية بلا حساب على الخادم، أو بلا شبكة — يُعاد عند فتح المتجر التالي
      debugPrint('AzmPush register: $e');
      _started = false;
    }
  }

  /// قبل الخروج: لا تصل الجهاز طلبات حساب لم يعد فيه.
  Future<void> stop() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    final t = _token;
    _token = null;
    _started = false;
    if (t != null) {
      try {
        await _ref.read(apiClientProvider).delete<dynamic>('/notify/devices/${Uri.encodeComponent(t)}');
      } catch (_) {}
    }
  }
}

final azmPushProvider = Provider<AzmPush>((ref) => AzmPush(ref));
