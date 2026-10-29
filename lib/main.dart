import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/tuner_theme.dart';
import 'state/scientific_mode_provider.dart';
import 'ui/screens/instrument_tuner_screen.dart';
import 'ui/screens/scientific_tuner_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TunerApp()));
}

/// Root widget of the Tuner Flutter application.
class TunerApp extends ConsumerWidget {
  const TunerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScientific = ref.watch(scientificModeProvider);

    return MaterialApp(
      title: 'Tuner',
      debugShowCheckedModeBanner: false,
      theme: TunerTheme.light(),
      darkTheme: TunerTheme.dark(),
      themeMode: ThemeMode.system,
      home: isScientific
          ? const ScientificTunerScreen()
          : const InstrumentTunerScreen(),
    );
  }
}
