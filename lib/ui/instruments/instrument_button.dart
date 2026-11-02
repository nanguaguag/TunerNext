import 'package:flutter/material.dart';

import '../../domain/instruments/instrument_icon.dart';
import '../plot/plot_window_outline.dart';
import 'instrument_icons.dart';

/// Top instrument selection card widget with outline, instrument vector icon, title, and optional error message.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.instruments.InstrumentButton`.
class InstrumentButton extends StatelessWidget {
  const InstrumentButton({
    super.key,
    required this.icon,
    required this.name,
    this.outline = const PlotWindowOutline(),
    this.errorMessage,
    this.onClick,
  });

  /// The instrument vector icon to display.
  final InstrumentIcon icon;

  /// The localized or custom name of the instrument.
  final String name;

  /// Corner radius, line width, and outline color.
  final PlotWindowOutline outline;

  /// Optional error message (e.g. "Incorrect temperament for instrument").
  /// When non-null, changes border to error color and background to errorContainer.
  final String? errorMessage;

  /// Click/tap callback (typically opens instrument picker/editor).
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasError = errorMessage != null;

    final borderColor = hasError
        ? colorScheme.error
        : (outline.color ?? colorScheme.outline);

    final backgroundColor = hasError
        ? colorScheme.errorContainer
        : colorScheme.surface;

    final contentColor = hasError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurface;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(outline.cornerRadius),
        side: BorderSide(color: borderColor, width: outline.lineWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onClick,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension, // 48.0 dp
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: InstrumentIconWidget(
                  icon: icon,
                  size: 36.0,
                  color: contentColor,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: contentColor,
                        ),
                      ),
                      if (hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            errorMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
