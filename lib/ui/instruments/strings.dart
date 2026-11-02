import 'package:flutter/material.dart';

import '../../core/theme/tuner_colors.dart';
import '../../domain/models/musical_note.dart';
import '../../domain/models/tuning_state.dart';
import '../plot/plot_window_outline.dart';
import 'scroll_icons.dart';
import 'string_with_info.dart';

/// Interactive instrument strings sidebar and fretboard view.
///
/// Displays physical strings with thickness proportional to acoustic gauge,
/// auto-centering on detected notes, pill-shaped pitch labels, and sidebar controls.
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.instruments.Strings.kt`.
class Strings extends StatefulWidget {
  const Strings({
    super.key,
    required this.strings,
    this.tuningState = TuningState.unknown,
    this.highlightedNoteKey,
    this.highlightedNote,
    this.sidebarPosition = StringsSidebarPosition.end,
    this.sidebarWidth = 32.0,
    this.outline = const PlotWindowOutline(),
    this.onStringClicked,
    this.scrollMode = StringsScrollMode.automatic,
    this.onScrollModeChanged,
  });

  /// The list of instrument strings (from lowest pitch to highest).
  final List<StringWithInfo> strings;

  /// Acoustic tuning state of the current pitch.
  final TuningState tuningState;

  /// Key of the currently highlighted target string.
  final int? highlightedNoteKey;

  /// Musical note of the currently highlighted target string.
  final MusicalNote? highlightedNote;

  /// Placement of the scroll action sidebar (start/left or end/right).
  final StringsSidebarPosition sidebarPosition;

  /// Width of the sidebar column in logical pixels.
  final double sidebarWidth;

  /// Outer border frame parameters.
  final PlotWindowOutline outline;

  /// Callback when a string is tapped.
  final void Function(int key, MusicalNote note)? onStringClicked;

  /// Initial or external scroll mode.
  final StringsScrollMode scrollMode;

  /// Callback when scroll mode changes between manual and automatic.
  final ValueChanged<StringsScrollMode>? onScrollModeChanged;

  @override
  State<Strings> createState() => _StringsState();
}

class _StringsState extends State<Strings> {
  late ScrollController _scrollController;
  late StringsScrollMode _scrollMode;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollMode = widget.scrollMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlighted());
  }

  @override
  void didUpdateWidget(covariant Strings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedNoteKey != oldWidget.highlightedNoteKey ||
        widget.highlightedNote != oldWidget.highlightedNote) {
      if (_scrollMode == StringsScrollMode.automatic) {
        _scrollToHighlighted();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _findTargetIndex() {
    if (widget.strings.isEmpty) return -1;
    if (widget.highlightedNoteKey != null) {
      final idx = widget.strings.indexWhere(
        (s) => s.key == widget.highlightedNoteKey,
      );
      if (idx != -1) return idx;
    }
    if (widget.highlightedNote != null) {
      final idx = widget.strings.indexWhere(
        (s) => s.note == widget.highlightedNote,
      );
      if (idx != -1) return idx;
    }
    return -1;
  }

  void _scrollToHighlighted() {
    if (!_scrollController.hasClients || widget.strings.isEmpty) return;
    final targetIdx = _findTargetIndex();
    if (targetIdx < 0) return;

    const itemHeight = 44.0;
    final viewportHeight = _scrollController.position.viewportDimension;
    final targetOffset =
        (targetIdx * itemHeight) - (viewportHeight / 2.0) + (itemHeight / 2.0);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToNextMatching() {
    if (widget.strings.isEmpty || widget.highlightedNote == null) return;
    final currentIdx = _findTargetIndex();
    final matchingIndices = <int>[];
    for (var i = 0; i < widget.strings.length; i++) {
      if (widget.strings[i].note == widget.highlightedNote) {
        matchingIndices.add(i);
      }
    }
    if (matchingIndices.length <= 1) return;

    final currMatchPos = matchingIndices.indexOf(currentIdx);
    final nextIdx =
        matchingIndices[(currMatchPos + 1) % matchingIndices.length];

    const itemHeight = 44.0;
    final viewportHeight = _scrollController.position.viewportDimension;
    final targetOffset =
        (nextIdx * itemHeight) - (viewportHeight / 2.0) + (itemHeight / 2.0);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _setManualScroll() {
    if (_scrollMode != StringsScrollMode.manual) {
      setState(() {
        _scrollMode = StringsScrollMode.manual;
      });
      widget.onScrollModeChanged?.call(StringsScrollMode.manual);
    }
  }

  void _resetToAutomatic() {
    setState(() {
      _scrollMode = StringsScrollMode.automatic;
    });
    widget.onScrollModeChanged?.call(StringsScrollMode.automatic);
    _scrollToHighlighted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tunerColors = TunerColors.of(context);

    final borderColor = widget.outline.color ?? colorScheme.outline;

    final matchingCount = widget.highlightedNote != null
        ? widget.strings.where((s) => s.note == widget.highlightedNote).length
        : 0;

    final sidebar = SizedBox(
      width: widget.sidebarWidth,
      child: Center(
        child: _scrollMode == StringsScrollMode.manual
            ? ScrollCenterIcon(
                color: colorScheme.primary,
                onTap: _resetToAutomatic,
              )
            : (matchingCount > 1
                  ? ScrollNextIcon(
                      color: colorScheme.primary,
                      onTap: _scrollToNextMatching,
                    )
                  : const SizedBox.shrink()),
      ),
    );

    final stringList = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          _setManualScroll();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.strings.length,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (context, index) {
          final item = widget.strings[index];
          final isHighlighted =
              item.key == widget.highlightedNoteKey ||
              (widget.highlightedNoteKey == null &&
                  item.note == widget.highlightedNote);

          // Compute gauge thickness (lowest string at index 0 has maximum width)
          final lineWidth = computeStringLineWidth(
            index: index,
            minIndex: 0,
            maxIndex: widget.strings.length - 1,
            minLineWidth: 1.0,
            maxLineWidth: 4.0,
          );

          // Resolve active tuning colors
          Color activeBgColor;
          Color activeTextColor;
          if (isHighlighted) {
            switch (widget.tuningState) {
              case TuningState.inTune:
                activeBgColor = tunerColors.positive;
                activeTextColor = tunerColors.onPositive;
                break;
              case TuningState.tooLow:
              case TuningState.tooHigh:
                activeBgColor = tunerColors.negative;
                activeTextColor = tunerColors.onNegative;
                break;
              case TuningState.unknown:
                activeBgColor = colorScheme.primary;
                activeTextColor = colorScheme.onPrimary;
                break;
            }
          } else {
            activeBgColor = colorScheme.surfaceContainerHigh;
            activeTextColor = colorScheme.onSurfaceVariant;
          }

          final stringLineColor = isHighlighted
              ? activeBgColor
              : colorScheme.outlineVariant;

          return InkWell(
            onTap: () {
              widget.onStringClicked?.call(item.key, item.note);
            },
            child: SizedBox(
              height: 44.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Horizontal string line across the entire row
                  Positioned(
                    left: 0,
                    right: 0,
                    height: lineWidth,
                    child: Container(color: stringLineColor),
                  ),
                  // Note pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: activeBgColor,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow:
                          isHighlighted &&
                              widget.tuningState == TuningState.inTune
                          ? [
                              BoxShadow(
                                color: tunerColors.positive.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 6.0,
                                spreadRadius: 1.0,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      item.note.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: activeTextColor,
                        fontWeight: isHighlighted ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(widget.outline.cornerRadius),
        border: Border.all(color: borderColor, width: widget.outline.lineWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          if (widget.sidebarPosition == StringsSidebarPosition.start) sidebar,
          Expanded(child: stringList),
          if (widget.sidebarPosition == StringsSidebarPosition.end) sidebar,
        ],
      ),
    );
  }
}
