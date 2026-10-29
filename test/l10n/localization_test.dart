// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/preferences/preferences_models.dart';
import 'package:tuner_flutter/l10n/app_localizations.dart';

void main() {
  group('16-Language Localization Tests', () {
    test(
      'All 16 supported locales load successfully without throwing',
      () async {
        for (final option in LanguageOption.supportedLanguages) {
          if (option.locale == null) continue; // system default
          final l10n = await AppLocalizations.delegate.load(option.locale!);
          expect(l10n, isNotNull);
          expect(l10n.appName.isNotEmpty, isTrue);
          expect(l10n.settings.isNotEmpty, isTrue);
          expect(l10n.pitchAlgorithm.isNotEmpty, isTrue);
        }
      },
    );

    test('English (en) strings match baseline audit specifications', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.appName, 'Tuner');
      expect(l10n.settings, 'Settings');
      expect(l10n.basic, 'Basic');
      expect(l10n.expert, 'Expert');
      expect(l10n.others, 'Others');
      expect(l10n.advancedAcousticDsp, 'Advanced Acoustic DSP');
      expect(l10n.keepScreenOn, 'Keep screen on');
      expect(l10n.resetAllSettings, 'Reset all settings');
      expect(l10n.scientificMode, 'Scientific mode');
      expect(l10n.toleranceInCents, 'Tolerance');
    });

    test('Simplified Chinese (zh) strings are accurate', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(l10n.appName, '调音器');
      expect(l10n.settings, '设置');
      expect(l10n.basic, '基础');
      expect(l10n.expert, '专家');
      expect(l10n.others, '其它');
      expect(l10n.advancedAcousticDsp, '进阶声学实验室 (DSP)');
      expect(l10n.keepScreenOn, '保持屏幕打开');
      expect(l10n.resetAllSettings, '重置所有设置');
    });

    test('German (de) strings are accurate', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('de'));
      expect(l10n.appName, 'Tuner');
      expect(l10n.settings, 'Einstellungen');
      expect(l10n.basic, 'Allgemein');
      expect(l10n.expert, 'Experten');
      expect(l10n.others, 'Andere');
      expect(l10n.keepScreenOn, 'Bildschirm immer an');
    });

    test('French (fr) strings are accurate', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
      expect(l10n.appName, 'Tuner');
      expect(l10n.settings, 'Paramètres');
      expect(l10n.basic, 'Basique');
      expect(l10n.expert, 'Expert');
    });

    test('Arabic (ar) strings load and Arabic locale is configured', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
      expect(l10n.appName, 'Tuner');
      expect(l10n.toleranceInCents, 'Tolerance');
      final arOption = LanguageOption.supportedLanguages.firstWhere(
        (opt) => opt.locale?.languageCode == 'ar',
      );
      expect(arOption.nativeName, 'العربية');
    });

    test('Plural and placeholder formatters operate correctly', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.hertz(440), '440 Hz');
      expect(l10n.toleranceSummary(5), '±5 ¢');
      expect(l10n.numMovingAverageSummary(1), 'No averaging');
      expect(l10n.numMovingAverageSummary(5), 'Average over 5 pitch results');
    });
  });
}
