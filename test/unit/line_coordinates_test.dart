import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/ui/plot/gesture_based_viewport.dart';
import 'package:tuner_flutter/ui/plot/line_coordinates.dart';

void main() {
  group('LineCoordinates Unit Tests', () {
    test('Default and list constructor', () {
      final empty = LineCoordinates();
      expect(empty.isEmpty, isTrue);
      expect(empty.size, 0);

      final coords = LineCoordinates([const Offset(1, 2), const Offset(3, 4)]);
      expect(coords.size, 2);
      expect(coords[0], const Offset(1, 2));
      expect(coords[1], const Offset(3, 4));
    });

    test('create pairs x and y coordinates correctly', () {
      final lc = LineCoordinates.create([10, 20, 30], [0.1, 0.5, 0.9]);
      expect(lc.size, 3);
      expect(lc[0], const Offset(10, 0.1));
      expect(lc[1], const Offset(20, 0.5));
      expect(lc[2], const Offset(30, 0.9));
    });

    test('fromY creates sequence with index as x', () {
      final lc = LineCoordinates.fromY([0.5, 1.0, 1.5]);
      expect(lc.size, 3);
      expect(lc[0], const Offset(0, 0.5));
      expect(lc[1], const Offset(1, 1.0));
      expect(lc[2], const Offset(2, 1.5));
    });

    test('mutate creates new instance with updated coordinates', () {
      final lc = LineCoordinates.create([1, 2], [3, 4]);
      final updated = lc.mutate([10, 20], [30, 40]);
      expect(updated.size, 2);
      expect(updated[0], const Offset(10, 30));
    });
  });

  group('GestureBasedViewPort Unit Tests', () {
    test('Initial state and finish reset', () {
      final vp = GestureBasedViewPort();
      expect(vp.isActive, isFalse);
      expect(vp.viewPort, isNull);

      vp.setViewPort(const Rect.fromLTRB(0, 1, 100, 0));
      expect(vp.isActive, isTrue);
      expect(vp.viewPort, const Rect.fromLTRB(0, 1, 100, 0));

      vp.finish();
      expect(vp.isActive, isFalse);
      expect(vp.viewPort, isNull);
    });

    test('Pan shifts viewport', () {
      final vp = GestureBasedViewPort();
      const base = Rect.fromLTRB(0, 1, 100, 0);
      vp.pan(10, 0, base);

      expect(vp.isActive, isTrue);
      expect(vp.viewPort?.left, -10);
      expect(vp.viewPort?.right, 90);
    });

    test('Zoom scales viewport', () {
      final vp = GestureBasedViewPort();
      const base = Rect.fromLTRB(0, 1, 100, 0);
      vp.zoom(2.0, 1.0, 0.5, 0.5, base);

      expect(vp.isActive, isTrue);
      // Width scaled from 100 by factor 2 -> 50 around center 50 -> [25, 75]
      expect(vp.viewPort?.width, closeTo(50.0, 1e-4));
      expect(vp.viewPort?.left, closeTo(25.0, 1e-4));
      expect(vp.viewPort?.right, closeTo(75.0, 1e-4));
    });
  });
}
