import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';
import '../plot/gesture_based_viewport.dart';
import '../plot/line_coordinates.dart';
import '../plot/plot_window_outline.dart';

/// Real-time autocorrelation and difference function waveform plot.
class CorrelationPlot extends StatefulWidget {
  const CorrelationPlot({
    super.key,
    required this.correlationPlotData,
    this.correlationPlotDataYZeroPosition = 0.5,
    this.targetNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.targetFrequency = 440.0,
    this.gestureBasedViewPort,
    this.currentFrequency,
    this.plotWindowOutline = const PlotWindowOutline(),
    this.lineColor,
    this.lineWidth = 2.0,
    this.tickLineColor,
    this.tickLineWidth = 1.0,
    this.currentFrequencyColor,
    this.currentFrequencyLineWidth = 1.5,
  });

  final LineCoordinates correlationPlotData;
  final double correlationPlotDataYZeroPosition;
  final MusicalNote targetNote;
  final double targetFrequency;
  final GestureBasedViewPort? gestureBasedViewPort;
  final double? currentFrequency;
  final PlotWindowOutline plotWindowOutline;

  final Color? lineColor;
  final double lineWidth;
  final Color? tickLineColor;
  final double tickLineWidth;
  final Color? currentFrequencyColor;
  final double currentFrequencyLineWidth;

  @override
  State<CorrelationPlot> createState() => _CorrelationPlotState();
}

class _CorrelationPlotState extends State<CorrelationPlot> {
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
  void didUpdateWidget(CorrelationPlot oldWidget) {
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
    var targetFreq = widget.targetFrequency;
    if (targetFreq <= 0.0) targetFreq = 440.0;
    final maxTimeLag = math.max(0.005, 2.5 / targetFreq);
    return Rect.fromLTRB(0.0, 1.0, maxTimeLag, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor = widget.lineColor ?? theme.colorScheme.onSurface;
    final effectiveTickColor =
        widget.tickLineColor ??
        theme.colorScheme.outline.withValues(alpha: 0.5);
    final effectiveCurrentFreqColor =
        widget.currentFrequencyColor ?? theme.colorScheme.primary;

    final baseViewPort = _computeBaseViewPort();
    final effectiveViewPort = _viewPort.viewPort ?? baseViewPort;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _viewPort.finish();
      },
      onScaleStart: (details) {
        _prevScale = 1.0;
        _prevFocal = details.localFocalPoint;
      },
      onScaleUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final size = renderBox.size;
        if (size.width <= 0) return;

        final dxPixels = details.localFocalPoint.dx - _prevFocal.dx;
        final currentVp = _viewPort.viewPort ?? baseViewPort;
        final dxPlot = (dxPixels / size.width) * currentVp.width;

        final scaleDelta = details.scale / _prevScale;
        _prevScale = details.scale;
        _prevFocal = details.localFocalPoint;

        final focalXFactor = (details.localFocalPoint.dx / size.width).clamp(
          0.0,
          1.0,
        );

        if ((scaleDelta - 1.0).abs() > 0.01) {
          _viewPort.zoom(
            scaleDelta,
            1.0,
            focalXFactor,
            0.5,
            baseViewPort,
            limits: const Rect.fromLTRB(0.0, 1.0, 0.5, 0.0),
          );
        } else if (dxPixels.abs() > 0.5) {
          _viewPort.pan(
            dxPlot,
            0.0,
            baseViewPort,
            limits: const Rect.fromLTRB(0.0, 1.0, 0.5, 0.0),
          );
        }
      },
      child: CustomPaint(
        painter: _CorrelationPlotPainter(
          data: widget.correlationPlotData,
          yZeroPosition: widget.correlationPlotDataYZeroPosition,
          viewPort: effectiveViewPort,
          currentFrequency: widget.currentFrequency,
          outline: widget.plotWindowOutline,
          lineColor: effectiveLineColor,
          lineWidth: widget.lineWidth,
          tickLineColor: effectiveTickColor,
          tickLineWidth: widget.tickLineWidth,
          currentFrequencyColor: effectiveCurrentFreqColor,
          currentFrequencyLineWidth: widget.currentFrequencyLineWidth,
          textStyle:
              theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10),
          isActiveGesture: _viewPort.isActive,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _CorrelationPlotPainter extends CustomPainter {
  _CorrelationPlotPainter({
    required this.data,
    required this.yZeroPosition,
    required this.viewPort,
    required this.currentFrequency,
    required this.outline,
    required this.lineColor,
    required this.lineWidth,
    required this.tickLineColor,
    required this.tickLineWidth,
    required this.currentFrequencyColor,
    required this.currentFrequencyLineWidth,
    required this.textStyle,
    required this.isActiveGesture,
  });

  final LineCoordinates data;
  final double yZeroPosition;
  final Rect viewPort;
  final double? currentFrequency;
  final PlotWindowOutline outline;
  final Color lineColor;
  final double lineWidth;
  final Color tickLineColor;
  final double tickLineWidth;
  final Color currentFrequencyColor;
  final double currentFrequencyLineWidth;
  final TextStyle textStyle;
  final bool isActiveGesture;

  static const double _bottomPadding = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= _bottomPadding) return;

    final plotArea = Rect.fromLTWH(
      0.0,
      0.0,
      size.width,
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
            ? currentFrequencyColor
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
    final xSpan = math.max(1e-6, xMax - xMin);

    double xToPlot(double timeLag) =>
        plotArea.left + ((timeLag - xMin) / xSpan) * plotArea.width;
    double yToPlot(double val) =>
        plotArea.bottom - (val.clamp(0.0, 1.0)) * plotArea.height;

    // Draw X-Ticks with inverse Hz labels
    _paintXTicks(canvas, size, plotArea, xMin, xMax, xToPlot);

    // Clip to plot area for waveform and horizontal line
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(plotArea, Radius.circular(outline.cornerRadius)),
    );

    // Draw horizontal zero line
    final yZeroPx = yToPlot(yZeroPosition);
    final zeroLinePaint = Paint()
      ..color = tickLineColor.withValues(alpha: 0.4)
      ..strokeWidth = tickLineWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(plotArea.left, yZeroPx),
      Offset(plotArea.right, yZeroPx),
      zeroLinePaint,
    );

    // Draw correlation curve
    if (data.size > 1) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      var started = false;

      for (var i = 0; i < data.size; i++) {
        final pt = data[i];
        final px = xToPlot(pt.dx);
        final py = yToPlot(pt.dy);

        if (!started) {
          path.moveTo(px, py);
          started = true;
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw current frequency marker at lag tau = 1.0 / f
    if (currentFrequency != null && currentFrequency! > 0) {
      final curF = currentFrequency!;
      final tau = 1.0 / curF;
      if (tau >= xMin && tau <= xMax) {
        final fx = xToPlot(tau);
        final curPaint = Paint()
          ..color = currentFrequencyColor
          ..strokeWidth = currentFrequencyLineWidth
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(fx, plotArea.top),
          Offset(fx, plotArea.bottom),
          curPaint,
        );
      }
    }

    canvas.restore();

    // Draw current frequency badge
    if (currentFrequency != null && currentFrequency! > 0) {
      final curF = currentFrequency!;
      final tau = 1.0 / curF;
      if (tau >= xMin && tau <= xMax) {
        final fx = xToPlot(tau);
        final badgeText = '${curF.toStringAsFixed(1)} Hz';
        final textPainter = TextPainter(
          text: TextSpan(
            text: badgeText,
            style: textStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 9.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final badgeW = textPainter.width + 8.0;
        final badgeH = textPainter.height + 4.0;
        final badgeX = (fx - badgeW / 2).clamp(4.0, size.width - badgeW - 4.0);
        final badgeY = plotArea.top + 4.0;

        final badgeRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
          const Radius.circular(4.0),
        );
        canvas.drawRRect(
          badgeRRect,
          Paint()
            ..color = currentFrequencyColor
            ..style = PaintingStyle.fill,
        );
        textPainter.paint(canvas, Offset(badgeX + 4.0, badgeY + 2.0));
      }
    }
  }

  void _paintXTicks(
    Canvas canvas,
    Size size,
    Rect plotArea,
    double xMin,
    double xMax,
    double Function(double) xToPlot,
  ) {
    final resolutions = [
      0.0002,
      0.0005,
      0.001,
      0.002,
      0.005,
      0.01,
      0.02,
      0.05,
      0.1,
    ];

    final span = xMax - xMin;
    var chosenDelta = resolutions.last;
    for (final delta in resolutions) {
      if (span / delta <= 6) {
        chosenDelta = delta;
        break;
      }
    }

    final tickPaint = Paint()
      ..color = tickLineColor
      ..strokeWidth = tickLineWidth;

    final firstTick = (xMin / chosenDelta).ceil() * chosenDelta;
    for (var tau = firstTick; tau <= xMax; tau += chosenDelta) {
      if (tau <= 1e-6) continue;
      final tx = xToPlot(tau);
      if (tx < plotArea.left || tx > plotArea.right) continue;

      canvas.drawLine(
        Offset(tx, plotArea.bottom),
        Offset(tx, plotArea.bottom + 4.0),
        tickPaint,
      );

      final freq = 1.0 / tau;
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

      final lx = (tx - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(lx, plotArea.bottom + 4.0));
    }
  }

  @override
  bool shouldRepaint(covariant _CorrelationPlotPainter old) {
    return old.data != data ||
        old.yZeroPosition != yZeroPosition ||
        old.viewPort != viewPort ||
        old.currentFrequency != currentFrequency ||
        old.isActiveGesture != isActiveGesture ||
        old.lineColor != lineColor ||
        old.outline != outline;
  }
}
