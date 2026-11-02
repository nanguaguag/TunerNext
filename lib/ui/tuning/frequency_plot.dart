import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';
import '../plot/gesture_based_viewport.dart';
import '../plot/line_coordinates.dart';
import '../plot/plot_window_outline.dart';

/// Real-time FFT spectrum plot displaying physical frequencies (Hz) vs normalized amplitudes.
class FrequencyPlot extends StatefulWidget {
  const FrequencyPlot({
    super.key,
    required this.frequencyPlotData,
    this.targetNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.targetFrequency = 440.0,
    this.gestureBasedViewPort,
    this.currentFrequency,
    this.harmonicFrequencies,
    this.plotWindowOutline = const PlotWindowOutline(),
    this.lineColor,
    this.lineWidth = 2.0,
    this.tickLineColor,
    this.tickLineWidth = 1.0,
    this.harmonicLineColor,
    this.harmonicLineWidth = 1.0,
    this.currentFrequencyColor,
    this.currentFrequencyLineWidth = 1.5,
  });

  final LineCoordinates frequencyPlotData;
  final MusicalNote targetNote;
  final double targetFrequency;
  final GestureBasedViewPort? gestureBasedViewPort;
  final double? currentFrequency;
  final List<double>? harmonicFrequencies;
  final PlotWindowOutline plotWindowOutline;

  final Color? lineColor;
  final double lineWidth;
  final Color? tickLineColor;
  final double tickLineWidth;
  final Color? harmonicLineColor;
  final double harmonicLineWidth;
  final Color? currentFrequencyColor;
  final double currentFrequencyLineWidth;

  @override
  State<FrequencyPlot> createState() => _FrequencyPlotState();
}

class _FrequencyPlotState extends State<FrequencyPlot> {
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
  void didUpdateWidget(FrequencyPlot oldWidget) {
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
    final maxFreq = math.max(100.0, targetFreq * 3.5);
    return Rect.fromLTRB(0.0, 1.0, maxFreq, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor = widget.lineColor ?? theme.colorScheme.onSurface;
    final effectiveTickColor =
        widget.tickLineColor ??
        theme.colorScheme.outline.withValues(alpha: 0.5);
    final effectiveHarmonicColor =
        widget.harmonicLineColor ?? theme.colorScheme.secondary;
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
            limits: const Rect.fromLTRB(0.0, 1.0, 20000.0, 0.0),
          );
        } else if (dxPixels.abs() > 0.5) {
          _viewPort.pan(
            dxPlot,
            0.0,
            baseViewPort,
            limits: const Rect.fromLTRB(0.0, 1.0, 20000.0, 0.0),
          );
        }
      },
      child: CustomPaint(
        painter: _FrequencyPlotPainter(
          data: widget.frequencyPlotData,
          viewPort: effectiveViewPort,
          currentFrequency: widget.currentFrequency,
          harmonicFrequencies: widget.harmonicFrequencies,
          outline: widget.plotWindowOutline,
          lineColor: effectiveLineColor,
          lineWidth: widget.lineWidth,
          tickLineColor: effectiveTickColor,
          tickLineWidth: widget.tickLineWidth,
          harmonicLineColor: effectiveHarmonicColor,
          harmonicLineWidth: widget.harmonicLineWidth,
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

class _FrequencyPlotPainter extends CustomPainter {
  _FrequencyPlotPainter({
    required this.data,
    required this.viewPort,
    required this.currentFrequency,
    required this.harmonicFrequencies,
    required this.outline,
    required this.lineColor,
    required this.lineWidth,
    required this.tickLineColor,
    required this.tickLineWidth,
    required this.harmonicLineColor,
    required this.harmonicLineWidth,
    required this.currentFrequencyColor,
    required this.currentFrequencyLineWidth,
    required this.textStyle,
    required this.isActiveGesture,
  });

  final LineCoordinates data;
  final Rect viewPort;
  final double? currentFrequency;
  final List<double>? harmonicFrequencies;
  final PlotWindowOutline outline;
  final Color lineColor;
  final double lineWidth;
  final Color tickLineColor;
  final double tickLineWidth;
  final Color harmonicLineColor;
  final double harmonicLineWidth;
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
    final xSpan = math.max(1e-4, xMax - xMin);

    double xToPlot(double freq) =>
        plotArea.left + ((freq - xMin) / xSpan) * plotArea.width;
    double yToPlot(double amp) =>
        plotArea.bottom - (amp.clamp(0.0, 1.0)) * plotArea.height;

    // Draw X-Ticks
    _paintXTicks(canvas, size, plotArea, xMin, xMax, xToPlot);

    // Clip to plot area for internal plot elements
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(plotArea, Radius.circular(outline.cornerRadius)),
    );

    // Draw harmonics
    if (harmonicFrequencies != null && harmonicFrequencies!.isNotEmpty) {
      final harmonicPaint = Paint()
        ..color = harmonicLineColor.withValues(alpha: 0.6)
        ..strokeWidth = harmonicLineWidth
        ..style = PaintingStyle.stroke;

      for (final hFreq in harmonicFrequencies!) {
        if (hFreq >= xMin && hFreq <= xMax) {
          final hx = xToPlot(hFreq);
          canvas.drawLine(
            Offset(hx, plotArea.top),
            Offset(hx, plotArea.bottom),
            harmonicPaint,
          );
        }
      }
    }

    // Draw spectrum curve
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

    // Draw current frequency marker
    if (currentFrequency != null && currentFrequency! > 0) {
      final curF = currentFrequency!;
      if (curF >= xMin && curF <= xMax) {
        final fx = xToPlot(curF);
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

    // Draw current frequency badge (outside clip if needed)
    if (currentFrequency != null && currentFrequency! > 0) {
      final curF = currentFrequency!;
      if (curF >= xMin && curF <= xMax) {
        final fx = xToPlot(curF);
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
    const candidateDeltas = [
      10.0,
      20.0,
      25.0,
      50.0,
      100.0,
      200.0,
      250.0,
      500.0,
      1000.0,
      2000.0,
      2500.0,
      5000.0,
      10000.0,
    ];

    final span = xMax - xMin;
    var chosenDelta = candidateDeltas.last;
    for (final delta in candidateDeltas) {
      if (span / delta <= 8) {
        chosenDelta = delta;
        break;
      }
    }

    final tickPaint = Paint()
      ..color = tickLineColor
      ..strokeWidth = tickLineWidth;

    final firstTick = (xMin / chosenDelta).ceil() * chosenDelta;
    for (var f = firstTick; f <= xMax; f += chosenDelta) {
      if (f <= 0) continue;
      final tx = xToPlot(f);
      if (tx < plotArea.left || tx > plotArea.right) continue;

      canvas.drawLine(
        Offset(tx, plotArea.bottom),
        Offset(tx, plotArea.bottom + 4.0),
        tickPaint,
      );

      final label = '${f.toInt()} Hz';
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
  bool shouldRepaint(covariant _FrequencyPlotPainter old) {
    return old.data != data ||
        old.viewPort != viewPort ||
        old.currentFrequency != currentFrequency ||
        old.harmonicFrequencies != harmonicFrequencies ||
        old.isActiveGesture != isActiveGesture ||
        old.lineColor != lineColor ||
        old.outline != outline;
  }
}
