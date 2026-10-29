import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/tuner_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TunerApp()));
}

/// Root widget of the Tuner Flutter application.
class TunerApp extends ConsumerWidget {
  const TunerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tuner',
      debugShowCheckedModeBanner: false,
      theme: TunerTheme.light(),
      darkTheme: TunerTheme.dark(),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tune, size: 64),
              SizedBox(height: 16),
              Text(
                'Tuner Flutter',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Phase 2: Architectural Foundation Ready'),
            ],
          ),
        ),
      ),
    );
  }
}
