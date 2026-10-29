import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/temperaments/predefined_temperaments.dart';
import 'package:tuner_flutter/domain/temperaments/temperament_io.dart';

void main() {
  group('TemperamentIO Scala (.scl) Format Tests', () {
    test('Valid cents Scala file parses accurately', () {
      const sclContent = '''! 12-EDO.scl
!
12-tone equal temperament
12
!
100.0
200.0
300.0
400.0
500.0
600.0
700.0
800.0
900.0
1000.0
1100.0
1200.0
''';

      final res = TemperamentIO.parseScala(sclContent);
      expect(res.isValid, isTrue);
      final t = res.temperament!;
      expect(t.size, 12);
      expect(t.name, '12-tone equal temperament');
      final cents = t.cents();
      expect(cents.length, 13);
      expect(cents[0], 0.0);
      expect(cents[7], closeTo(700.0, 1e-4));
      expect(cents[12], closeTo(1200.0, 1e-4));
    });

    test('Valid ratio Scala file parses fractions into cents', () {
      const sclRatioContent = '''! pure_major.scl
Just Intonation Triad
3
!
5/4
3/2
2/1
''';

      final res = TemperamentIO.parseScala(sclRatioContent);
      expect(res.isValid, isTrue);
      final t = res.temperament!;
      expect(t.size, 3);
      final cents = t.cents();
      expect(cents[1], closeTo(386.314, 1e-2)); // 5/4
      expect(cents[2], closeTo(701.955, 1e-2)); // 3/2
      expect(cents[3], closeTo(1200.0, 1e-2)); // 2/1
    });

    test('Invalid fraction (0/0) is rejected safely', () {
      const invalid = 'Bad scale\n1\n0/0\n';
      final res = TemperamentIO.parseScala(invalid);
      expect(res.isValid, isFalse);
    });

    test('Mismatch between note count header and entries is rejected', () {
      const mismatch = 'Test\n5\n100.0\n200.0\n';
      final res = TemperamentIO.parseScala(mismatch);
      expect(res.isValid, isFalse);
    });

    test(
      'Export and import round-trip preserves temperament cents and metadata',
      () {
        final original = PredefinedTemperaments.werckmeisterIII();
        final exported = TemperamentIO.exportToScala(original);

        final reimported = TemperamentIO.parseScala(exported);
        expect(reimported.isValid, isTrue);
        final t = reimported.temperament!;
        expect(t.size, original.size);

        final c1 = original.cents();
        final c2 = t.cents();
        for (var i = 0; i < c1.length; i++) {
          expect(c2[i], closeTo(c1[i], 1e-2));
        }
      },
    );
  });
}
