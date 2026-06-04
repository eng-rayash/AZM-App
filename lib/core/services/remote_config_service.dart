import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService instance = RemoteConfigService._();

  final _supabase = Supabase.instance.client;

  // Cache configuration values
  String minVersion = '0.1.0';
  String latestVersion = '0.1.0';
  bool maintenanceMode = false;
  String maintenanceMessage = 'نظام مديري حالياً في صيانة دورية المظهر والبيانات مجدولة للتحسين، يرجى المحاولة لاحقاً.';
  String storeUrl = 'https://play.google.com/store/apps/details?id=com.mudiri.mudiri';

  /// Check version requirements and maintenance mode.
  /// Queries the 'app_config' table in Supabase.
  /// Table structure:
  /// - id (int/uuid)
  /// - min_version (text) e.g. '0.1.0'
  /// - latest_version (text) e.g. '0.1.0'
  /// - maintenance_mode (boolean)
  /// - maintenance_message (text)
  /// - store_url (text)
  Future<void> fetchConfigs() async {
    try {
      // Limit search to 1 row, query table 'app_config'
      final response = await _supabase
          .from('app_config')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        minVersion = response['min_version'] ?? minVersion;
        latestVersion = response['latest_version'] ?? latestVersion;
        maintenanceMode = response['maintenance_mode'] ?? maintenanceMode;
        maintenanceMessage = response['maintenance_message'] ?? maintenanceMessage;
        storeUrl = response['store_url'] ?? storeUrl;
      }
    } catch (e) {
      // If table doesn't exist yet, or offline, we use the default fallback values.
      // This is a robust approach to prevent app crashes.
      debugPrint('RemoteConfigService error: $e. Using offline default configs.');
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
