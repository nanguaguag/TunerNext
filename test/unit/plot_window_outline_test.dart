import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner_flutter/ui/plot/plot_window_outline.dart';

void main() {
  group('PlotWindowOutline', () {
    test('default constructor values match Kotlin PlotWindowOutline', () {
      const outline = PlotWindowOutline();
      expect(outline.lineWidth, 1.0);
      expect(outline.cornerRadius, 8.0);
      expect(outline.color, isNull);
    });

    test('custom values and copyWith', () {
      const outline = PlotWindowOutline(
        lineWidth: 2.5,
        cornerRadius: 12.0,
        color: Colors.red,
      );
      expect(outline.lineWidth, 2.5);
      expect(outline.cornerRadius, 12.0);
      expect(outline.color, Colors.red);

      final modified = outline.copyWith(lineWidth: 3.0);
      expect(modified.lineWidth, 3.0);
      expect(modified.cornerRadius, 12.0);
      expect(modified.color, Colors.red);
    });

    test('equality and hashCode', () {
      const a = PlotWindowOutline(
        lineWidth: 1.5,
        cornerRadius: 6.0,
        color: Colors.blue,
      );
      const b = PlotWindowOutline(
        lineWidth: 1.5,
        cornerRadius: 6.0,
        color: Colors.blue,
      );
      const c = PlotWindowOutline(
        lineWidth: 2.0,
        cornerRadius: 6.0,
        color: Colors.blue,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
