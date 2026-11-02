import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/data/preferences/app_preferences.dart';
import 'package:tuner_flutter/domain/models/dsp_enums.dart';
import 'package:tuner_flutter/l10n/app_localizations.dart';
import 'package:tuner_flutter/ui/preferences/preference_dialogs.dart';
import 'package:tuner_flutter/ui/screens/preferences_screen.dart';

void main() {
  group('Settings Chinese Localization Coverage Tests', () {
    testWidgets(
      'PreferencesScreen subtitles render completely in Simplified Chinese',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final prefs = AppPreferences();

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PreferencesScreen(preferences: prefs)),
          ),
        );
        await tester.pumpAndSettle();

        // Check key translated subtitles in Chinese
        expect(find.text('调音过程中保持屏幕常亮'), findsOneWidget);
        expect(find.text('指示调准状态的绿色音分容差阈值'), findsOneWidget);
        expect(find.text('变音记号优先显示为降号 (♭) 而非升号 (♯)'), findsOneWidget);
        expect(find.text('在十二平均律半音模式下显示五线谱'), findsOneWidget);
        expect(find.text('音高检测的声音输入灵敏度门限'), findsOneWidget);

        // Verify no untranslated English subtitles for these items
        expect(
          find.text('Prevents display from sleeping while tuning'),
          findsNothing,
        );
        expect(
          find.text('Threshold for green pitch accuracy indicator'),
          findsNothing,
        );
        expect(
          find.text('Display accidentals as flat instead of sharp (♯)'),
          findsNothing,
        );
      },
    );

    testWidgets('Preference dialogs display accurate Chinese descriptions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: ctx,
                        builder: (_) => PitchAlgorithmDialog(
                          selectedAlgorithm: PitchAlgorithm.mpm,
                          onSelected: (_) {},
                        ),
                      );
                    },
                    child: const Text('Open Pitch Dialog'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap open dialog
      await tester.tap(find.text('Open Pitch Dialog'));
      await tester.pumpAndSettle();

      // Check Chinese description of MPM
      expect(find.text('高精度，针对琴弦起奏八度跳变具备强鲁棒性抑制。'), findsOneWidget);
      expect(find.text('双向失配频谱谐波匹配，攻克琴弦非谐性与缺失基频。'), findsOneWidget);
    });
  });
}
