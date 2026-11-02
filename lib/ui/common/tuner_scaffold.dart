import 'package:flutter/material.dart';

import '../../domain/models/musical_note.dart';
import 'quick_settings_bar.dart';

/// Top-level app scaffold providing synchronized M3 AppBar, action modes,
/// and permanent [QuickSettingsBar] bottom bar.
///
/// 1:1 parity with Kotlin `de.moekadu.tuner.ui.misc.TunerScaffold`.
class TunerScaffold extends StatelessWidget {
  const TunerScaffold({
    super.key,
    this.title = 'Tuner',
    this.canNavigateUp = false,
    this.onNavigateUpClicked,
    this.showPreferenceButton = true,
    this.onPreferenceButtonClicked,
    this.defaultModeTools = const [],
    this.actionModeActive = false,
    this.actionModeTitle = '',
    this.actionModeTools = const [],
    this.onActionModeFinishedClicked,
    this.showBottomBar = true,
    this.referenceNote = const MusicalNote(base: BaseNote.a, octave: 4),
    this.referenceFrequency = 440.0,
    this.temperamentName = 'EDO 12',
    this.preferFlat = false,
    this.stretchTuningName,
    this.onSharpFlatClicked,
    this.onTemperamentClicked,
    this.onReferenceNoteClicked,
    this.onStretchTuningClicked,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    required this.body,
  });

  final String title;
  final bool canNavigateUp;
  final VoidCallback? onNavigateUpClicked;
  final bool showPreferenceButton;
  final VoidCallback? onPreferenceButtonClicked;
  final List<Widget> defaultModeTools;

  final bool actionModeActive;
  final String actionModeTitle;
  final List<Widget> actionModeTools;
  final VoidCallback? onActionModeFinishedClicked;

  final bool showBottomBar;
  final MusicalNote referenceNote;
  final double referenceFrequency;
  final String temperamentName;
  final bool preferFlat;
  final String? stretchTuningName;
  final VoidCallback? onSharpFlatClicked;
  final VoidCallback? onTemperamentClicked;
  final VoidCallback? onReferenceNoteClicked;
  final VoidCallback? onStretchTuningClicked;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    if (actionModeActive) {
      leading = IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Close',
        onPressed: onActionModeFinishedClicked,
      );
    } else if (canNavigateUp) {
      leading = IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed:
            onNavigateUpClicked ?? () => Navigator.of(context).maybePop(),
      );
    }

    final actions = <Widget>[];
    if (actionModeActive) {
      actions.addAll(actionModeTools);
    } else {
      actions.addAll(defaultModeTools);
      if (showPreferenceButton) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: onPreferenceButtonClicked,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(actionModeActive ? actionModeTitle : title),
        leading: leading,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showBottomBar
          ? QuickSettingsBar(
              referenceNote: referenceNote,
              referenceFrequency: referenceFrequency,
              temperamentName: temperamentName,
              preferFlat: preferFlat,
              stretchTuningName: stretchTuningName,
              onSharpFlatClicked: onSharpFlatClicked,
              onTemperamentClicked: onTemperamentClicked,
              onReferenceNoteClicked: onReferenceNoteClicked,
              onStretchTuningClicked: onStretchTuningClicked,
            )
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
