import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/l10n/app_localizations.dart';

void main() {
  group('Slice 8.1: 16-Language Localization Unit Tests', () {
    const expectedLocales = [
      'en',
      'zh',
      'de',
      'es',
      'fr',
      'hu',
      'pl',
      'ro',
      'uk',
      'cs',
      'sv',
      'pt',
      'it',
      'ru',
      'ja',
      'vi',
    ];

    test('Supported locales contain exactly the 16 target languages', () {
      final supportedCodes = AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .toSet();

      for (final code in expectedLocales) {
        expect(
          supportedCodes.contains(code),
          isTrue,
          reason: 'Locale $code should be supported',
        );
      }
      expect(supportedCodes.length, equals(16));
    });

    test(
      'lookupAppLocalizations successfully resolves each supported locale',
      () {
        for (final code in expectedLocales) {
          final locale = Locale(code);
          final l10n = lookupAppLocalizations(locale);
          expect(l10n, isNotNull);
          expect(l10n.appName.isNotEmpty, isTrue);
          expect(l10n.instrumentTuner.isNotEmpty, isTrue);
          expect(l10n.scientificTuner.isNotEmpty, isTrue);
          expect(l10n.settings.isNotEmpty, isTrue);
        }
      },
    );

    test('Specific translations match expected localized terms', () {
      // English
      final en = lookupAppLocalizations(const Locale('en'));
      expect(en.instrumentTuner, equals('Instrument Tuner'));
      expect(en.scientificTuner, equals('Scientific Tuner'));
      expect(en.unlock, equals('Unlock'));
      expect(en.settings, equals('Settings'));

      // Chinese (Simplified)
      final zh = lookupAppLocalizations(const Locale('zh'));
      expect(zh.instrumentTuner, equals('乐器调音'));
      expect(zh.scientificTuner, equals('科学调音'));
      expect(zh.unlock, equals('解锁'));
      expect(zh.settings, equals('设置'));

      // German
      final de = lookupAppLocalizations(const Locale('de'));
      expect(de.instrumentTuner, equals('Instrumentenstimmer'));
      expect(de.scientificTuner, equals('Wissenschaftlicher Stimmer'));
      expect(de.unlock, equals('Entsperren'));
      expect(de.settings, equals('Einstellungen'));

      // Spanish
      final es = lookupAppLocalizations(const Locale('es'));
      expect(es.instrumentTuner, equals('Afinador de instrumentos'));
      expect(es.scientificTuner, equals('Afinador científico'));
      expect(es.unlock, equals('Desbloquear'));
      expect(es.settings, equals('Ajustes'));

      // French
      final fr = lookupAppLocalizations(const Locale('fr'));
      expect(fr.instrumentTuner, equals("Accordeur d'instrument"));
      expect(fr.scientificTuner, equals('Accordeur scientifique'));
      expect(fr.unlock, equals('Déverrouiller'));
      expect(fr.settings, equals('Paramètres'));

      // Japanese
      final ja = lookupAppLocalizations(const Locale('ja'));
      expect(ja.instrumentTuner, equals('楽器チューナー'));
      expect(ja.scientificTuner, equals('サイエンティフィックチューナー'));
      expect(ja.unlock, equals('ロック解除'));

      // Russian
      final ru = lookupAppLocalizations(const Locale('ru'));
      expect(ru.instrumentTuner, equals('Тюнер инструментов'));
      expect(ru.scientificTuner, equals('Научный тюнер'));
      expect(ru.unlock, equals('Разблокировать'));
    });

    test('Parameterized strings format correctly without runtime errors', () {
      final zh = lookupAppLocalizations(const Locale('zh'));
      expect(zh.recordingExported('test.wav'), contains('test.wav'));
      expect(zh.exportFailed('IO Error'), contains('IO Error'));
      expect(zh.lockedString('A4'), contains('A4'));
      expect(zh.hertz(440), equals('440 Hz'));
      expect(zh.percent(50), equals('50%'));

      final en = lookupAppLocalizations(const Locale('en'));
      expect(
        en.recordingExported('take1.wav'),
        equals('Recording exported: take1.wav'),
      );
      expect(en.lockedString('E2'), equals('Locked String: E2'));
      expect(en.exportFailed('Timeout'), equals('Export failed: Timeout'));
    });

    test(
      'Plural strings resolve accurately for single and multiple quantities',
      () {
        final en = lookupAppLocalizations(const Locale('en'));
        expect(en.itemsDeleted(1), equals('1 item deleted'));
        expect(en.itemsDeleted(5), equals('5 items deleted'));
        expect(
          en.pitchHistoryNumFaultyValuesSummary(1),
          equals('Directly jump to new pitch result'),
        );
        expect(
          en.pitchHistoryNumFaultyValuesSummary(3),
          equals('After 3 similar pitch results'),
        );
      },
    );
  });
}
