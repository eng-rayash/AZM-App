// Web stub — no drift/native imports here.
// On web, backup is handled via Supabase cloud.
Future<bool> exportNative(dynamic logger, dynamic db) async => true;
Future<bool> restoreNative(dynamic logger, dynamic db) async => true;
Future<String> getDbSizeNative() async => 'Supabase Cloud';