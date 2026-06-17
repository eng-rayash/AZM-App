import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:mudiri/app.dart';
import 'package:mudiri/core/constants/app_constants.dart';

void main() {
  setUpAll(() async {
    // Ensure Flutter bindings are initialized for setting mock method call handlers
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock SharedPreferences method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      },
    );

    // Initialize Supabase with placeholder values for test environment
    await Supabase.initialize(
      url: 'https://psjlycjbaiacdzvtewvi.supabase.co',
      anonKey: 'sb_publishable_c1EhUj6faoPYiqy9vPucXg_m7pdb8pQ',
    );

    // Initialize timezones and set local location to UTC for test environment
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MudiriApp(),
      ),
    );

    // Verify that the splash screen displays the app name
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Pump the timer forward by the splash duration so that the navigation timer fires
    await tester.pump(const Duration(milliseconds: 1500));
    // Let the routing complete by pumping a few frames manually
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
