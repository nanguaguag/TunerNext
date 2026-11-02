import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuner_flutter/main.dart';
import 'package:tuner_flutter/ui/screens/instrument_tuner_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('TunerApp smoke test mounts with M3 and ProviderScope', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: TunerApp()));
    await tester.pumpAndSettle();

    expect(find.byType(TunerApp), findsOneWidget);
    expect(find.byType(InstrumentTunerScreen), findsOneWidget);
    expect(find.text('Tuner'), findsOneWidget);
  });
}
