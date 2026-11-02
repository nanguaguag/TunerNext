import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/l10n/app_localizations.dart';
import 'package:tuner_flutter/main.dart';
import 'package:tuner_flutter/ui/preferences/preference_dialogs.dart';

void main() {
  group('Slice 8.1: Multi-Language Widget Localization Tests', () {
    testWidgets('Renders Chinese text when locale is zh', (tester) async {
      final prefs = AppPreferences();
      prefs.language = 'zh';

      await tester.pumpWidget(
        ProviderScope(child: TunerApp(initialPreferences: prefs)),
      );
      await tester.pumpAndSettle();

      expect(find.text('调音器'), findsOneWidget);
      expect(find.byTooltip('科学调音'), findsOneWidget);
      expect(find.byTooltip('设置'), findsOneWidget);
    });

    testWidgets('Renders English text when locale is en', (tester) async {
      final prefs = AppPreferences();
      prefs.language = 'en';

      await tester.pumpWidget(
        ProviderScope(child: TunerApp(initialPreferences: prefs)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tuner'), findsOneWidget);
      expect(find.byTooltip('Scientific Tuner'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
    });

    testWidgets('Renders German text when locale is de', (tester) async {
      final prefs = AppPreferences();
      prefs.language = 'de';

      await tester.pumpWidget(
        ProviderScope(child: TunerApp(initialPreferences: prefs)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tuner'), findsOneWidget);
      expect(find.byTooltip('Wissenschaftlicher Stimmer'), findsOneWidget);
      expect(find.byTooltip('Einstellungen'), findsOneWidget);
    });

    testWidgets('Dynamically updates UI strings upon locale change', (
      tester,
    ) async {
      final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

      await tester.pumpWidget(
        ProviderScope(
          child: ValueListenableBuilder<Locale>(
            valueListenable: localeNotifier,
            builder: (context, locale, _) {
              return MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const TunerHomeScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially English
      expect(find.byTooltip('Scientific Tuner'), findsOneWidget);

      // Switch to Spanish
      localeNotifier.value = const Locale('es');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Afinador científico'), findsOneWidget);

      // Switch to French
      localeNotifier.value = const Locale('fr');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Accordeur scientifique'), findsOneWidget);

      // Switch to Japanese
      localeNotifier.value = const Locale('ja');
      await tester.pumpAndSettle();
      expect(find.byTooltip('サイエンティフィックチューナー'), findsOneWidget);
    });

    testWidgets(
      'LanguageDialog displays all 16 languages and selects properly',
      (tester) async {
        String? chosenLanguage;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => LanguageDialog(
                          selectedLanguage: 'en',
                          onSelected: (l) => chosenLanguage = l,
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Dialog is open
        expect(find.byType(LanguageDialog), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        expect(find.text('Deutsch (German)'), findsOneWidget);

        // Tap German
        await tester.tap(find.text('Deutsch (German)'));
        await tester.pumpAndSettle();

        expect(chosenLanguage, equals('de'));
      },
    );
  });
}
