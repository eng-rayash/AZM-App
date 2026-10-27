import 'package:flutter/foundation.dart';

import '../api/api_client.dart';

/// إعدادات التطبيق من الباكند الموحّد (`GET /app/config`) — تُضبط من إعدادات
/// المنصة في عزم سمارت (مفاتيح `app.*`): أدنى إصدار مسموح، ووضع الصيانة
/// ورسالته، ورابط المتجر.
///
/// بلا اتصال تبقى القيم الافتراضية أدناه: التطبيق يعمل محليًا ولا يُحجب
/// لأن الخادم لم يُطَل.
class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  // Cache configuration values
  String minVersion = '0.1.0';
  String latestVersion = '0.1.0';
  bool maintenanceMode = false;
  String maintenanceMessage = 'نظام عزم حالياً في صيانة دورية المظهر والبيانات مجدولة للتحسين، يرجى المحاولة لاحقاً.';
  String storeUrl = 'https://play.google.com/store/apps/details?id=com.mudiri.mudiri';

  Future<void> fetchConfigs() async {
    try {
      final r = await ApiClient().get('/app/config');
      minVersion = (r['minVersion'] as String?) ?? minVersion;
      latestVersion = (r['latestVersion'] as String?) ?? latestVersion;
      maintenanceMode = (r['maintenance'] as bool?) ?? maintenanceMode;
      maintenanceMessage = (r['maintenanceMessage'] as String?) ?? maintenanceMessage;
      storeUrl = (r['storeUrl'] as String?) ?? storeUrl;
    } catch (e) {
      debugPrint('RemoteConfigService: $e — تُستعمل القيم الافتراضية.');
    }
  }

  /// Helper to compare semantic versions (e.g., '0.1.0' vs '0.2.0')
  bool isVersionOlder(String current, String required) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final requiredParts = required.split('.').map(int.parse).toList();
      for (var i = 0; i < 3; i++) {
        final c = i < currentParts.length ? currentParts[i] : 0;
        final r = i < requiredParts.length ? requiredParts[i] : 0;
        if (c < r) return true;
        if (c > r) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}