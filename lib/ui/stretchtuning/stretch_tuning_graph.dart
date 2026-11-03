import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/stretch_tuning/stretch_tuning.dart';
import '../../domain/tuning/tuning_math.dart';
import '../plot/gesture_based_viewport.dart';
import '../plot/plot_window_outline.dart';

/// Interactive visualization of a Railsback acoustic stretch tuning curve.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.stretchtuning.StretchTuningGraph`.
/// - Horizontal axis: nominal frequency on a logarithmic scale (represented in relative cents vs reference frequency).
/// - Vertical axis: signed stretch amount in cents.
/// - Interactive pan and zoom gestures via [GestureBasedViewPort].
class StretchTuningGraph extends StatefulWidget {
  const StretchTuningGraph({
    super.key,
    required this.stretchTuning,
    this.selectedKey = StretchTuning.noKey,
    this.gestureBasedViewPort,
    this.referenceFrequency = 440.0,
    this.plotWindowOutline = const PlotWindowOutline(),
    this.lineColor,
    this.lineWidth = 2.0,
    this.pointColor,
    this.pointRadius = 4.0,
    this.selectedPointColor,
    this.selectedPointRadius = 6.0,
    this.tickLineColor,
    this.tickLineWidth = 1.0,
    this.zeroLineColor,
    this.zeroLineWidth = 1.5,
  });

  final StretchTuning stretchTuning;
  final int selectedKey;
  final GestureBasedViewPort? gestureBasedViewPort;
  final double referenceFrequency;
  final PlotWindowOutline plotWindowOutline;

  final Color? lineColor;
  final double lineWidth;
  final Color? pointColor;
  final double pointRadius;
  final Color? selectedPointColor;
  final double selectedPointRadius;
  final Color? tickLineColor;
  final double tickLineWidth;
  final Color? zeroLineColor;
  final double zeroLineWidth;

  @override
  State<StretchTuningGraph> createState() => _StretchTuningGraphState();
}

class _StretchTuningGraphState extends State<StretchTuningGraph> {
  late GestureBasedViewPort _viewPort;
  double _prevScale = 1.0;
  Offset _prevFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _viewPort = widget.gestureBasedViewPort ?? GestureBasedViewPort();
    _viewPort.addListener(_onViewPortChanged);
  }

  @override
  void didUpdateWidget(StretchTuningGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gestureBasedViewPort != oldWidget.gestureBasedViewPort) {
      _viewPort.removeListener(_onViewPortChanged);
      _viewPort = widget.gestureBasedViewPort ?? GestureBasedViewPort();
      _viewPort.addListener(_onViewPortChanged);
    }
  }

  @override
  void dispose() {
    _viewPort.removeListener(_onViewPortChanged);
    super.dispose();
  }

  void _onViewPortChanged() {
    setState(() {});
  }

  Rect _computeBaseViewPort() {
    final st = widget.stretchTuning;
    final fRef = widget.referenceFrequency;

    double fMin, fMax;
    if (st.isEmpty) {
      fMin = fRef * 0.5;
      fMax = fRef * 2.0;
    } else if (st.size == 1) {
      fMin = st.unstretchedFrequencies.first * 0.5;
      fMax = st.unstretchedFrequencies.first * 2.0;
    } else {
      fMin = st.unstretchedFrequencies.reduce(math.min);
      fMax = st.unstretchedFrequencies.reduce(math.max);
    }

    final fMinCents = TuningMath.ratioToCents(fMin / fRef);
    final fMaxCents = TuningMath.ratioToCents(fMax / fRef);
    final fMargin = math.max(100.0, (fMaxCents - fMinCents) * 0.05);

    double cMin, cMax;
    if (st.isEmpty) {
      cMin = -15.0;
      cMax = 15.0;
    } else if (st.size == 1) {
      cMin = math.min(-10.0, st.stretchInCents.first - 5.0);
      cMax = math.max(10.0, st.stretchInCents.first + 5.0);
    } else {
      cMin = st.stretchInCents.reduce(math.min);
      cMax = st.stretchInCents.reduce(math.max);
    }
    if ((cMax - cMin).abs() < 5.0) {
      cMin -= 5.0;
      cMax += 5.0;
    }
    final cMargin = (cMax - cMin) * 0.05;

    return Rect.fromLTRB(
      fMinCents - fMargin,
      cMax + cMargin,
      fMaxCents + fMargin,
      cMin - cMargin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor = widget.lineColor ?? theme.colorScheme.primary;
    final effectivePointColor = widget.pointColor ?? theme.colorScheme.primary;
    final effectiveSelectedPointColor =
        widget.selectedPointColor ?? theme.colorScheme.error;
    final effectiveTickColor =
        widget.tickLineColor ??
        theme.colorScheme.outline.withValues(alpha: 0.5);
    final effectiveZeroColor =
        widget.zeroLineColor ?? theme.colorScheme.outline;

    final baseViewPort = _computeBaseViewPort();
    final effectiveViewPort = _viewPort.viewPort ?? baseViewPort;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _viewPort.finish(),
      onScaleStart: (details) {
        _prevScale = 1.0;
        _prevFocal = details.localFocalPoint;
      },
      onScaleUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final size = renderBox.size;
        if (size.width <= 0 || size.height <= 0) return;

        final dxPixels = details.localFocalPoint.dx - _prevFocal.dx;
        final dyPixels = details.localFocalPoint.dy - _prevFocal.dy;
        final currentVp = _viewPort.viewPort ?? baseViewPort;
        final dxPlot = (dxPixels / size.width) * currentVp.width;
        final dyPlot = (dyPixels / size.height) * currentVp.height;

        final scaleDelta = details.scale / _prevScale;
        _prevScale = details.scale;
        _prevFocal = details.localFocalPoint;

        final focalXFactor = (details.localFocalPoint.dx / size.width).clamp(
          0.0,
          1.0,
        );
        final focalYFactor = (details.localFocalPoint.dy / size.height).clamp(
          0.0,
          1.0,
        );

        if ((scaleDelta - 1.0).abs() > 0.01) {
          _viewPort.zoom(
            scaleDelta,
            scaleDelta,
            focalXFactor,
            focalYFactor,
            baseViewPort,
          );
        } else if (dxPixels.abs() > 0.5 || dyPixels.abs() > 0.5) {
          _viewPort.pan(dxPlot, dyPlot, baseViewPort);
        }
      },
      child: CustomPaint(
        painter: _StretchTuningGraphPainter(
          stretchTuning: widget.stretchTuning,
          selectedKey: widget.selectedKey,
          referenceFrequency: widget.referenceFrequency,
          viewPort: effectiveViewPort,
          outline: widget.plotWindowOutline,
          lineColor: effectiveLineColor,
          lineWidth: widget.lineWidth,
          pointColor: effectivePointColor,
          pointRadius: widget.pointRadius,
          selectedPointColor: effectiveSelectedPointColor,
          selectedPointRadius: widget.selectedPointRadius,
          tickLineColor: effectiveTickColor,
          tickLineWidth: widget.tickLineWidth,
          zeroLineColor: effectiveZeroColor,
          zeroLineWidth: widget.zeroLineWidth,
          textStyle:
              theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10),
          isActiveGesture: _viewPort.isActive,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _StretchTuningGraphPainter extends CustomPainter {
  _StretchTuningGraphPainter({
    required this.stretchTuning,
    required this.selectedKey,
    required this.referenceFrequency,
    required this.viewPort,
    required this.outline,
    required this.lineColor,
    required this.lineWidth,
    required this.pointColor,
    required this.pointRadius,
    required this.selectedPointColor,
    required this.selectedPointRadius,
    required this.tickLineColor,
    required this.tickLineWidth,
    required this.zeroLineColor,
    required this.zeroLineWidth,
    required this.textStyle,
    required this.isActiveGesture,
  });

  final StretchTuning stretchTuning;
  final int selectedKey;
  final double referenceFrequency;
  final Rect viewPort;
  final PlotWindowOutline outline;
  final Color lineColor;
  final double lineWidth;
  final Color pointColor;
  final double pointRadius;
  final Color selectedPointColor;
  final double selectedPointRadius;
  final Color tickLineColor;
  final double tickLineWidth;
  final Color zeroLineColor;
  final double zeroLineWidth;
  final TextStyle textStyle;
  final bool isActiveGesture;

  static const double _bottomPadding = 20.0;
  static const double _rightPadding = 42.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= _rightPadding || size.height <= _bottomPadding) return;

    final plotArea = Rect.fromLTWH(
      0.0,
      0.0,
      size.width - _rightPadding,
      size.height - _bottomPadding,
    );

    // Draw background
    if (outline.color != null && outline.color != Colors.transparent) {
      final bgPaint = Paint()
        ..color = outline.color!.withValues(
          alpha: isActiveGesture ? 0.08 : 0.04,
        )
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          plotArea,
          Radius.circular(outline.cornerRadius),
        ),
        bgPaint,
      );
    }

    // Draw border
    if (outline.lineWidth > 0) {
      final borderPaint = Paint()
        ..color = isActiveGesture
            ? selectedPointColor
            : (outline.color?.withValues(alpha: 0.3) ??
                  lineColor.withValues(alpha: 0.3))
        ..strokeWidth = outline.lineWidth
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          plotArea,
          Radius.circular(outline.cornerRadius),
        ),
        borderPaint,
      );
    }

    final xMin = viewPort.left;
    final xMax = viewPort.right;
    final xSpan = math.max(1e-4, xMax - xMin);

    final yMin = viewPort.bottom;
    final yMax = viewPort.top;
    final ySpan = math.max(1e-4, yMax - yMin);

    double xToPlot(double c) =>
        plotArea.left + ((c - xMin) / xSpan) * plotArea.width;
    double yToPlot(double s) =>
        plotArea.bottom - ((s - yMin) / ySpan) * plotArea.height;

    // Draw Ticks & Labels
    _paintXTicks(canvas, size, plotArea, xMin, xMax, xToPlot);
    _paintYTicks(canvas, size, plotArea, yMin, yMax, yToPlot);

    // Clip to plot area for lines, points, and zero guides
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(plotArea, Radius.circular(outline.cornerRadius)),
    );

    // Draw zero stretch horizontal line (y = 0)
    if (0.0 >= yMin && 0.0 <= yMax) {
      final y0 = yToPlot(0.0);
      final zeroPaint = Paint()
        ..color = zeroLineColor.withValues(alpha: 0.5)
        ..strokeWidth = zeroLineWidth
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(plotArea.left, y0),
        Offset(plotArea.right, y0),
        zeroPaint,
      );
    }

    // Draw reference frequency vertical line (x = 0)
    if (0.0 >= xMin && 0.0 <= xMax) {
      final x0 = xToPlot(0.0);
      final refPaint = Paint()
        ..color = zeroLineColor.withValues(alpha: 0.5)
        ..strokeWidth = zeroLineWidth
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(x0, plotArea.top),
        Offset(x0, plotArea.bottom),
        refPaint,
      );
    }

    // Prepare point coordinates
    final points = <Offset>[];
    Offset? selectedPoint;

    for (var i = 0; i < stretchTuning.size; i++) {
      final f = stretchTuning.unstretchedFrequencies[i];
      final s = stretchTuning.stretchInCents[i];
      final key = stretchTuning.keys[i];

      final c = TuningMath.ratioToCents(f / referenceFrequency);
      final pt = Offset(xToPlot(c), yToPlot(s));
      points.add(pt);

      if (key == selectedKey) {
        selectedPoint = pt;
      }
    }

    // Draw polyline connecting points
    if (points.length > 1) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw node points
    final ptPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;
    for (final pt in points) {
      canvas.drawCircle(pt, pointRadius, ptPaint);
    }

    // Draw highlighted selected point
    if (selectedPoint != null) {
      final selPaint = Paint()
        ..color = selectedPointColor
        ..style = PaintingStyle.fill;
      final selHalo = Paint()
        ..color = selectedPointColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(selectedPoint, selectedPointRadius + 4.0, selHalo);
      canvas.drawCircle(selectedPoint, selectedPointRadius, selPaint);
    }

    canvas.restore();
  }

  void _paintXTicks(
    Canvas canvas,
    Size size,
    Rect plotArea,
    double xMin,
    double xMax,
    double Function(double) xToPlot,
  ) {
    const candidateDeltas = [300.0, 600.0, 1200.0, 2400.0];
    final span = xMax - xMin;
    var delta = candidateDeltas.last;
    for (final d in candidateDeltas) {
      if (span / d <= 6) {
        delta = d;
        break;
      }
    }

    final tickPaint = Paint()
      ..color = tickLineColor
      ..strokeWidth = tickLineWidth;

    final firstTick = (xMin / delta).ceil() * delta;
    for (var c = firstTick; c <= xMax; c += delta) {
      final tx = xToPlot(c);
      if (tx < plotArea.left || tx > plotArea.right) continue;

      canvas.drawLine(
        Offset(tx, plotArea.bottom),
        Offset(tx, plotArea.bottom + 4.0),
        tickPaint,
      );

      final freq = TuningMath.centsToFrequency(c, referenceFrequency);
      final label = freq >= 100
          ? '${freq.round()} Hz'
          : '${freq.toStringAsFixed(1)} Hz';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(color: textStyle.color ?? tickLineColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final lx = (tx - tp.width / 2).clamp(0.0, plotArea.right - tp.width / 2);
      tp.paint(canvas, Offset(lx, plotArea.bottom + 4.0));
    }
  }

  void _paintYTicks(
    Canvas canvas,
    Size size,
    Rect plotArea,
    double yMin,
    double yMax,
    double Function(double) yToPlot,
  ) {
    const candidateDeltas = [2.0, 5.0, 10.0, 20.0, 50.0, 100.0];
    final span = yMax - yMin;
    var delta = candidateDeltas.last;
    for (final d in candidateDeltas) {
      if (span / d <= 7) {
        delta = d;
        break;
      }
    }

    final tickPaint = Paint()
      ..color = tickLineColor
      ..strokeWidth = tickLineWidth;

    final firstTick = (yMin / delta).ceil() * delta;
    for (var s = firstTick; s <= yMax; s += delta) {
      final ty = yToPlot(s);
      if (ty < plotArea.top || ty > plotArea.bottom) continue;

      canvas.drawLine(
        Offset(plotArea.right, ty),
        Offset(plotArea.right + 4.0, ty),
        tickPaint,
      );

      final sInt = s.round();
      final label = sInt > 0 ? '+$sInt ¢' : '$sInt ¢';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(color: textStyle.color ?? tickLineColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(plotArea.right + 6.0, ty - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _StretchTuningGraphPainter old) {
    return old.stretchTuning != stretchTuning ||
        old.selectedKey != selectedKey ||
        old.referenceFrequency != referenceFrequency ||
        old.viewPort != viewPort ||
        old.outline != outline ||
        old.isActiveGesture != isActiveGesture;
  }
}
