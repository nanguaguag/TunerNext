import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Manages interactive viewport transformations (pan and zoom gestures) for plots.
class GestureBasedViewPort extends ChangeNotifier {
  GestureBasedViewPort({bool initialIsActive = false, Rect? initialViewPort})
    : _isActive = initialIsActive,
      _viewPort = initialViewPort;

  bool _isActive;
  Rect? _viewPort;

  /// Whether an active user gesture has overridden the default viewport.
  bool get isActive => _isActive;

  /// Current gesture-transformed viewport bounds.
  Rect? get viewPort => _viewPort;

  /// Resets the viewport back to default non-gesture mode.
  void finish() {
    if (_isActive || _viewPort != null) {
      _isActive = false;
      _viewPort = null;
      notifyListeners();
    }
  }

  /// Sets an explicit viewport and marks the viewport as active.
  void setViewPort(Rect rect, {Rect? limits}) {
    _isActive = true;
    _viewPort = _restrictToLimits(rect, limits);
    notifyListeners();
  }

  /// Pans the current viewport by delta `[dx, dy]` in plot coordinate space.
  void pan(double dx, double dy, Rect baseViewPort, {Rect? limits}) {
    final current = _viewPort ?? baseViewPort;
    final shifted = Rect.fromLTRB(
      current.left - dx,
      current.top - dy,
      current.right - dx,
      current.bottom - dy,
    );
    setViewPort(shifted, limits: limits);
  }

  /// Scales the viewport horizontally and vertically around [focalFactor] (0.0 to 1.0).
  void zoom(
    double scaleX,
    double scaleY,
    double focalXFactor,
    double focalYFactor,
    Rect baseViewPort, {
    Rect? limits,
  }) {
    final current = _viewPort ?? baseViewPort;
    final curWidth = current.width;
    final curHeight = current.height;

    final widthSign = curWidth < 0 ? -1.0 : 1.0;
    final heightSign = curHeight < 0 ? -1.0 : 1.0;

    final newWidth = widthSign * (curWidth.abs() / scaleX).clamp(1e-4, 1e7);
    final newHeight = heightSign * (curHeight.abs() / scaleY).clamp(1e-4, 1e7);

    final focalX = current.left + curWidth * focalXFactor;
    final focalY = current.top + curHeight * focalYFactor;

    final newLeft = focalX - newWidth * focalXFactor;
    final newTop = focalY - newHeight * focalYFactor;

    final zoomed = Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
    setViewPort(zoomed, limits: limits);
  }

  Rect _restrictToLimits(Rect rect, Rect? limits) {
    if (limits == null) return rect;
    var left = rect.left;
    var right = rect.right;
    var top = rect.top;
    var bottom = rect.bottom;

    if (limits.left.isFinite && left < limits.left) {
      final w = rect.width;
      left = limits.left;
      right = left + w;
    }
    if (limits.right.isFinite && right > limits.right) {
      final w = rect.width;
      right = limits.right;
      left = right - w;
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
