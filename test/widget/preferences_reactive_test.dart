import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/ui/screens/preferences_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'PreferencesScreen changing appearance triggers notification and updates themeMode',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final prefs = AppPreferences();
      int notificationCount = 0;
      prefs.addListener(() {
        notificationCount++;
      });

      await tester.pumpWidget(
        MaterialApp(home: PreferencesScreen(preferences: prefs)),
      );
      await tester.pumpAndSettle();

      expect(prefs.themeMode, ThemeMode.system);

      // Tap Appearance
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.text('Dark'), findsOneWidget);

      // Select Dark mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(prefs.themeMode, ThemeMode.dark);
      expect(notificationCount, greaterThan(0));
    },
  );
}
