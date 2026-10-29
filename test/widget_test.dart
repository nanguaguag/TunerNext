import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/main.dart';

void main() {
  testWidgets('TunerApp smoke test mounts with M3 and ProviderScope', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TunerApp()));
    expect(find.text('Tuner Flutter'), findsOneWidget);
    expect(
      find.text('Phase 2: Architectural Foundation Ready'),
      findsOneWidget,
    );
  });
}
