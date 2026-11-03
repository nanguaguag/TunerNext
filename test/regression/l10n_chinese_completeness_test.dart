import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/l10n/app_localizations.dart';

void main() {
  group(
    'Regression Test: BUG-P1-07 Simplified Chinese Localization Completeness',
    () {
      test(
        'Simplified Chinese localizations resolve accurate professional music terms',
        () async {
          final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

          // Core actions
          expect(l10n.instruments, equals('乐器管理'));
          expect(l10n.temperaments, equals('历史与现代律制'));
          expect(l10n.edit, equals('编辑'));
          expect(l10n.copy, equals('复制'));
          expect(l10n.delete, equals('删除'));
          expect(l10n.save, equals('保存'));

          // Temperaments
          expect(l10n.equalTemperament12, equals('十二平均律'));
          expect(l10n.pythagoreanTuning, contains('毕达哥拉斯'));
          expect(l10n.pureTuning, contains('纯律'));
          expect(l10n.quarterCommaMeanTone, contains('¼'));
          expect(l10n.werckmeisterIii, contains('韦克迈斯特'));
          expect(l10n.kirnberger1, contains('柯恩伯格'));
          expect(l10n.neidhardt1, contains('诺伊哈特'));

          // Clef & Notation
          expect(l10n.staffClef, equals('谱号'));
          expect(l10n.staffClefTreble, contains('高音谱号'));
          expect(l10n.staffClefBass, contains('低音谱号'));
          expect(l10n.staffClefTenor, contains('次中音谱号'));
          expect(l10n.chromaticAsStaff, equals('半音阶调音器五线谱显示'));

          // Stretch & Hardware
          expect(l10n.stretch, equals('延展'));
          expect(l10n.stretchTuning, equals('延展调音'));
          expect(l10n.railsback, contains('雷尔斯贝克'));
          expect(l10n.audioRecordPermissionRationale, contains('麦克风'));
          expect(l10n.soundSourceMicrophoneUnavailable, contains('无法访问麦克风设备'));
        },
      );
    },
  );
}
