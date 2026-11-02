import 'dart:math' as math;
import 'dart:ui';

/// Encapsulates a sequence of 2D coordinates `(x, y)` for plotting graphs.
class LineCoordinates {
  LineCoordinates([List<Offset>? initialCoordinates])
    : coordinates = initialCoordinates ?? const [];

  /// Ordered list of points.
  final List<Offset> coordinates;

  /// Number of coordinate points.
  int get size => coordinates.length;

  /// Whether the coordinate sequence is empty.
  bool get isEmpty => coordinates.isEmpty;

  /// Whether the coordinate sequence is not empty.
  bool get isNotEmpty => coordinates.isNotEmpty;

  /// Returns the point at [index].
  Offset operator [](int index) => coordinates[index];

  /// Creates a [LineCoordinates] instance from separate [x] and [y] arrays.
  static LineCoordinates create(List<double> x, List<double> y) {
    final count = math.min(x.length, y.length);
    final coords = List<Offset>.generate(
      count,
      (i) => Offset(x[i], y[i]),
      growable: false,
    );
    return LineCoordinates(coords);
  }

  /// Creates a [LineCoordinates] instance where x is index `0, 1, 2, ...` and y is [y].
  static LineCoordinates fromY(List<double> y) {
    final coords = List<Offset>.generate(
      y.length,
      (i) => Offset(i.toDouble(), y[i]),
      growable: false,
    );
    return LineCoordinates(coords);
  }

  /// Returns a new [LineCoordinates] with updated [x] and [y] values.
  LineCoordinates mutate(List<double> x, List<double> y) {
    return LineCoordinates.create(x, y);
  }
}
