import '../models/rational_number.dart';
import 'temperament_models.dart';

/// Result of parsing a Scala (.scl) temperament file or string.
class TemperamentParseResult {
  const TemperamentParseResult({
    required this.isValid,
    this.temperament,
    this.errorMessage,
  });

  final bool isValid;
  final TemperamentCustom? temperament;
  final String? errorMessage;
}

/// Parser and serializer for the Huygens-Fokker Scala (.scl) tuning format.
class TemperamentIO {
  static const versionKey = 'Version';
  static const abbrKey = 'Abbr';
  static const descKey = 'Desc';
  static const noteKey = 'Note';

  /// Serializes a [Temperament] into standard Scala (.scl) text format.
  static String exportToScala(Temperament temperament) {
    final buffer = StringBuffer();
    final name = temperament.name.replaceAll('\n', ' ');
    final abbr = temperament.abbreviation.replaceAll('\n', ' ');
    final desc = temperament.description.replaceAll('\n', ' ');

    buffer.writeln('! ${name.replaceAll(' ', '_')}.scl');
    if (abbr.isNotEmpty) buffer.writeln('! $abbrKey=$abbr');
    if (desc.isNotEmpty) buffer.writeln('! $descKey=$desc');
    buffer.writeln('!');
    buffer.writeln(name);
    buffer.writeln(temperament.size);
    buffer.writeln('!');

    final cents = temperament.cents();
    final ratios = temperament.rationalNumbers();

    for (var i = 1; i <= temperament.size; i++) {
      if (ratios != null && i < ratios.length) {
        final r = ratios[i];
        buffer.writeln(' ${r.numerator}/${r.denominator}');
      } else if (i < cents.length) {
        buffer.writeln(' ${cents[i].toStringAsFixed(2)}');
      }
    }

    return buffer.toString();
  }

  /// Parses a Scala (.scl) string and extracts cent values and ratios.
  static TemperamentParseResult parseScala(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    String? name;
    String? abbreviation;
    String? description;
    var expectedNoteCount = -1;
    final parsedCents = <double>[0.0]; // Root note is always 0.0 cents
    final parsedRatios = <RationalNumber>[RationalNumber(1, 1)];

    var inHeader = true;

    for (var rawLine in lines) {
      var line = rawLine.trim();
      // Skip UTF-8 BOM
      if (line.startsWith('\ufeff')) {
        line = line.substring(1).trim();
      }
      if (line.isEmpty) continue;

      if (line.startsWith('!')) {
        final comment = line.substring(1).trim();
        final eqIdx = comment.indexOf('=');
        if (eqIdx > 0) {
          final k = comment.substring(0, eqIdx).trim();
          final v = comment.substring(eqIdx + 1).trim();
          if (k == abbrKey) abbreviation = v;
          if (k == descKey) description = v;
        }
        continue;
      }

      if (inHeader) {
        if (name == null) {
          name = line;
          continue;
        }
        if (expectedNoteCount < 0) {
          final count = int.tryParse(line);
          if (count == null || count <= 0) {
            return const TemperamentParseResult(
              isValid: false,
              errorMessage: 'Invalid note count in Scala header.',
            );
          }
          expectedNoteCount = count;
          inHeader = false;
          continue;
        }
      }

      // Parse pitch value (cents or ratio)
      // Line might have inline comments or whitespace
      final tokens = line.split(RegExp(r'\s+'));
      if (tokens.isEmpty) continue;
      final valueToken = tokens[0];

      if (valueToken.contains('.')) {
        // Cents line
        final c = double.tryParse(valueToken);
        if (c == null) {
          return TemperamentParseResult(
            isValid: false,
            errorMessage: 'Invalid cent value: $valueToken',
          );
        }
        parsedCents.add(c);
      } else if (valueToken.contains('/')) {
        // Fraction ratio (e.g., 3/2)
        final parts = valueToken.split('/');
        if (parts.length != 2) {
          return TemperamentParseResult(
            isValid: false,
            errorMessage: 'Invalid fraction ratio: $valueToken',
          );
        }
        final num = int.tryParse(parts[0]);
        final den = int.tryParse(parts[1]);
        if (num == null || den == null || den == 0 || num == 0) {
          return TemperamentParseResult(
            isValid: false,
            errorMessage: 'Invalid fraction numbers: $valueToken',
          );
        }
        final r = RationalNumber(num, den);
        parsedRatios.add(r);
        parsedCents.add(ratioToCents(r.toDouble()));
      } else {
        // Integer ratio (e.g. 2 for octave)
        final intRatio = int.tryParse(valueToken);
        if (intRatio == null || intRatio <= 0) {
          return TemperamentParseResult(
            isValid: false,
            errorMessage: 'Invalid integer ratio: $valueToken',
          );
        }
        final r = RationalNumber(intRatio, 1);
        parsedRatios.add(r);
        parsedCents.add(ratioToCents(r.toDouble()));
      }
    }

    if (expectedNoteCount < 0 || parsedCents.length - 1 != expectedNoteCount) {
      return TemperamentParseResult(
        isValid: false,
        errorMessage:
            'Parsed note count (${parsedCents.length - 1}) did not match header ($expectedNoteCount).',
      );
    }

    final temperament = TemperamentCustom(
      name: name ?? 'Imported Temperament',
      abbreviation: abbreviation ?? 'Custom',
      description: description ?? 'Imported from Scala .scl file',
      centValues: parsedCents,
      stableId: DateTime.now().millisecondsSinceEpoch,
      ratioList: parsedRatios.length == parsedCents.length
          ? parsedRatios
          : null,
    );

    return TemperamentParseResult(isValid: true, temperament: temperament);
  }
}
