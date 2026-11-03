// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/ui/staff/note_staff_painter.dart';
import 'package:tuner_flutter/ui/staff/svg_path_parser.dart';

void main() {
  group('SvgPathParser Tests', () {
    test('Parses basic M, L, C, and Z commands into non-empty Path', () {
      const sample = 'M0 0 L10 10 C10 20 20 20 30 10 Z';
      final path = SvgPathParser.parse(sample);
      expect(path, isNotNull);
      final bounds = path.getBounds();
      expect(bounds.left, equals(0.0));
      expect(bounds.top, equals(0.0));
      expect(bounds.right, greaterThan(0.0));
      expect(bounds.bottom, greaterThan(0.0));
    });

    test('Parses Gonville trebleClefPathData accurately', () {
      final treblePath = SvgPathParser.parse(trebleClefPathData);
      expect(treblePath, isNotNull);
      final bounds = treblePath.getBounds();
      // Verify bounded in reasonable staff space coordinate range
      expect(bounds.top, lessThan(0.0)); // Extends upwards past G line
      expect(bounds.bottom, greaterThan(0.0)); // Extends downwards past G line
      expect(bounds.width, greaterThan(1.0));
    });

    test('Parses Gonville bassClefPathData accurately', () {
      final bassPath = SvgPathParser.parse(bassClefPathData);
      expect(bassPath, isNotNull);
      final bounds = bassPath.getBounds();
      expect(bounds.top, lessThan(0.0));
      expect(bounds.bottom, greaterThan(0.0));
      expect(bounds.width, greaterThan(1.0));
    });

    test(
      'Handles unknown commands with arguments without infinite loop (BUG-09)',
      () {
        // Unknown command 'X' with multiple arguments followed by known 'M' and 'Z'
        const inputWithUnknown = 'X 10 20 30 Y 40 50 M 0 0 L 10 10 Z';
        final path = SvgPathParser.parse(inputWithUnknown);
        expect(path, isNotNull);
        final bounds = path.getBounds();
        expect(bounds.right, equals(10.0));
      },
    );

    test('Handles truncated commands and orphan tokens without crashing', () {
      // Incomplete commands
      expect(() => SvgPathParser.parse('10 20 M 5'), returnsNormally);
      expect(() => SvgPathParser.parse('C 1 2 3'), returnsNormally);
      expect(() => SvgPathParser.parse('Q 1 2'), returnsNormally);
      expect(() => SvgPathParser.parse('H'), returnsNormally);
      expect(() => SvgPathParser.parse(''), returnsNormally);
    });

    test('Parses H, V, and Q commands accurately', () {
      const sample = 'M 0 0 H 20 V 30 Q 25 35 30 40 Z';
      final path = SvgPathParser.parse(sample);
      expect(path, isNotNull);
      final bounds = path.getBounds();
      expect(bounds.right, greaterThanOrEqualTo(20.0));
      expect(bounds.bottom, greaterThanOrEqualTo(30.0));
    });
  });
}
