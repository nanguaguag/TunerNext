// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/domain/models/instrument.dart';

void main() {
  group('Instrument Domain Model Tests', () {
    test('All 9 predefined instruments exist with valid string setups', () {
      final instruments = PredefinedInstruments.getAll();
      expect(instruments.length, 9);

      final chromatic = PredefinedInstruments.chromatic;
      expect(chromatic.isChromatic, isTrue);
      expect(chromatic.strings.isEmpty, isTrue);

      final guitar = PredefinedInstruments.guitar6String;
      expect(guitar.isChromatic, isFalse);
      expect(guitar.strings.length, 6);
      expect(guitar.strings.first.name, 'E2');
      expect(guitar.strings.last.name, 'E4');

      final violin = PredefinedInstruments.violin;
      expect(violin.strings.length, 4);
      expect(violin.strings.first.name, 'G3');
      expect(violin.strings.last.name, 'E5');
    });

    test('String order transformations (lowToHigh and highToLow)', () {
      final guitar = PredefinedInstruments.guitar6String;
      final highToLow = guitar.stringsHighToLow;
      final lowToHigh = guitar.stringsLowToHigh;

      expect(highToLow.first.name, 'E4');
      expect(highToLow.last.name, 'E2');

      expect(lowToHigh.first.name, 'E2');
      expect(lowToHigh.last.name, 'E4');
    });
  });
}
