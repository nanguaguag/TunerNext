import '../models/musical_note.dart';
import 'keyboard_mapping.dart';
import 'scala_note_helper.dart';
import 'scala_scale.dart';

/// Status of a Scala file parsing operation.
enum ScalaFileStatus { ok, empty, invalid }

/// Encapsulates the complete result of parsing a Scala (.scl) file or text stream.
class ScalaParseResult {
  const ScalaParseResult({
    required this.status,
    required this.scales,
    this.errors = const [],
  });

  /// Factory for an empty file result.
  factory ScalaParseResult.empty([List<String> errors = const []]) {
    return ScalaParseResult(
      status: ScalaFileStatus.empty,
      scales: const [],
      errors: errors,
    );
  }

  /// Factory for an invalid file result.
  factory ScalaParseResult.invalid(List<String> errors) {
    return ScalaParseResult(
      status: ScalaFileStatus.invalid,
      scales: const [],
      errors: errors,
    );
  }

  /// Factory for a successful parse.
  factory ScalaParseResult.success(List<ScalaScale> scales) {
    return ScalaParseResult(
      status: ScalaFileStatus.ok,
      scales: scales,
      errors: const [],
    );
  }

  final ScalaFileStatus status;
  final List<ScalaScale> scales;
  final List<String> errors;

  bool get isOk => status == ScalaFileStatus.ok;
  bool get isEmpty => status == ScalaFileStatus.empty;
  bool get isInvalid => status == ScalaFileStatus.invalid;

  /// Returns the first parsed scale if available, or null.
  ScalaScale? get singleScaleOrNull => scales.isNotEmpty ? scales.first : null;
}

/// Parser for Huygens-Fokker Scala scale (.scl) and keyboard mapping (.kbm) formats.
class ScalaParser {
  const ScalaParser();

  static const String _versionKey = 'version';
  static const String _abbreviationKey = 'abbreviation';
  static const String _descriptionKey = 'description';

  /// Parses a Scala (.scl) file string, potentially containing one or multiple scale definitions.
  ScalaParseResult parseScl(String content) {
    if (content.trim().isEmpty) {
      return ScalaParseResult.empty();
    }

    final scales = <ScalaScale>[];
    final errors = <String>[];

    // Strip optional UTF-8 BOM
    final sanitized = content.startsWith('\uFEFF')
        ? content.substring(1)
        : content;

    final lines = sanitized.split(RegExp(r'\r?\n'));

    String? version;
    String? abbreviation;
    String? explicitDescription;
    String? scaleName;
    int numberOfNotes = -1;
    final currentIntervals = <ScalaPitchInterval>[];

    var lineNum = 0;

    for (final rawLine in lines) {
      lineNum++;
      final line = rawLine.trim();

      // Check for comment line
      if (line.startsWith('!')) {
        final commentMetadata = _parseCommentMetadata(line);
        if (commentMetadata != null) {
          switch (commentMetadata.key) {
            case _versionKey:
              version = commentMetadata.value;
              break;
            case _abbreviationKey:
              abbreviation = commentMetadata.value;
              break;
            case _descriptionKey:
              explicitDescription = commentMetadata.value;
              break;
          }
        }
        continue;
      }

      // Skip blank lines
      if (line.isEmpty) {
        continue;
      }

      // 1. First non-comment line is scale name/description
      if (scaleName == null) {
        scaleName = line;
        continue;
      }

      // 2. Second non-comment line is number of notes
      if (numberOfNotes < 0) {
        final n = int.tryParse(line);
        if (n == null || n < 0) {
          errors.add(
            'Line $lineNum: Invalid scale size "$line". Expected non-negative integer.',
          );
          return ScalaParseResult.invalid(errors);
        }
        numberOfNotes = n;

        // An empty scale (0 notes)
        if (numberOfNotes == 0) {
          scales.add(
            ScalaScale(
              name: scaleName,
              abbreviation: abbreviation ?? '',
              description: explicitDescription ?? scaleName,
              version: version ?? '',
              intervals: const [],
            ),
          );
          // Reset state for potential next scale in stream
          scaleName = null;
          abbreviation = null;
          explicitDescription = null;
          numberOfNotes = -1;
          currentIntervals.clear();
        }
        continue;
      }

      // 3. Subsequent lines are interval pitches
      final interval = _parseIntervalLine(line, lineNum, errors);
      if (interval == null) {
        return ScalaParseResult.invalid(errors);
      }
      currentIntervals.add(interval);

      // Once we have collected all declared notes
      if (currentIntervals.length == numberOfNotes) {
        scales.add(
          ScalaScale(
            name: scaleName,
            abbreviation: abbreviation ?? '',
            description: explicitDescription ?? scaleName,
            version: version ?? '',
            intervals: List.unmodifiable(currentIntervals),
          ),
        );

        // Reset state for potential subsequent scale
        scaleName = null;
        abbreviation = null;
        explicitDescription = null;
        numberOfNotes = -1;
        currentIntervals.clear();
      }
    }

    // Check if the file was truncated mid-scale
    if (numberOfNotes > 0 && currentIntervals.length < numberOfNotes) {
      errors.add(
        'Truncated file: Expected $numberOfNotes pitch intervals, but only found ${currentIntervals.length}.',
      );
      return ScalaParseResult.invalid(errors);
    }

    if (scales.isEmpty) {
      return errors.isEmpty
          ? ScalaParseResult.empty()
          : ScalaParseResult.invalid(errors);
    }

    return ScalaParseResult.success(scales);
  }

  /// Parses a single pitch line (e.g., "100.0", "3/2", "9/8 note=D", "2").
  ScalaPitchInterval? _parseIntervalLine(
    String line,
    int lineNum,
    List<String> errors,
  ) {
    // Split into tokens by whitespace
    final tokens = line.split(RegExp(r'\s+'));
    if (tokens.isEmpty || tokens[0].isEmpty) {
      errors.add('Line $lineNum: Empty interval definition.');
      return null;
    }

    final pitchToken = tokens[0];

    // Check for note annotation in subsequent tokens (e.g. "note=D", "note=C#")
    MusicalNote? note;
    for (int i = 1; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.startsWith(ScalaNoteHelper.notePrefix)) {
        note = ScalaNoteHelper.parseNoteAssignment(token);
        break;
      }
    }

    // If it contains a decimal point, it's a cent value (e.g. 100.0 or 1200.)
    if (pitchToken.contains('.')) {
      final cents = double.tryParse(pitchToken);
      if (cents == null || cents.isNaN || cents.isInfinite) {
        errors.add('Line $lineNum: Malformed cents value "$pitchToken".');
        return null;
      }
      return ScalaPitchInterval.fromCents(cents, note: note, rawText: line);
    }

    // If it contains a slash, it's a rational fraction (e.g. 3/2, 5/4)
    if (pitchToken.contains('/')) {
      final parts = pitchToken.split('/');
      if (parts.length != 2) {
        errors.add(
          'Line $lineNum: Malformed ratio "$pitchToken". Expected numerator/denominator.',
        );
        return null;
      }
      final num = int.tryParse(parts[0]);
      final den = int.tryParse(parts[1]);
      if (num == null || den == null || den == 0) {
        errors.add(
          'Line $lineNum: Invalid ratio "$pitchToken" (zero denominator or non-integer).',
        );
        return null;
      }
      return ScalaPitchInterval.fromRatio(num, den, note: note, rawText: line);
    }

    // An integer with neither dot nor slash is an integer ratio with denominator 1 (e.g. 2 -> 2/1)
    final pureInt = int.tryParse(pitchToken);
    if (pureInt != null) {
      return ScalaPitchInterval.fromRatio(
        pureInt,
        1,
        note: note,
        rawText: line,
      );
    }

    errors.add(
      'Line $lineNum: Unrecognized pitch interval format "$pitchToken".',
    );
    return null;
  }

  /// Extracts key-value metadata from a comment line (e.g., "! version=1.0").
  _CommentMetadata? _parseCommentMetadata(String line) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('!')) return null;

    final content = trimmed.substring(1).trim();
    final equalsIndex = content.indexOf('=');
    if (equalsIndex <= 0) return null;

    final key = content.substring(0, equalsIndex).trim();
    final value = content.substring(equalsIndex + 1).trim();
    return _CommentMetadata(key, value);
  }

  /// Parses a Huygens-Fokker Keyboard Mapping (.kbm) file.
  KeyboardMapping parseKbm(String content) {
    final sanitized = content.startsWith('\uFEFF')
        ? content.substring(1)
        : content;

    final lines = sanitized.split(RegExp(r'\r?\n'));
    final nonCommentLines = <String>[];

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isNotEmpty && !line.startsWith('!')) {
        nonCommentLines.add(line);
      }
    }

    if (nonCommentLines.length < 7) {
      throw FormatException(
        'Incomplete .kbm file: Expected at least 7 header lines, but found ${nonCommentLines.length}.',
      );
    }

    final mapSize = int.parse(nonCommentLines[0]);
    final firstMidi = int.parse(nonCommentLines[1]);
    final lastMidi = int.parse(nonCommentLines[2]);
    final middleMidi = int.parse(nonCommentLines[3]);
    final referenceMidi = int.parse(nonCommentLines[4]);
    final referenceFreq = double.parse(nonCommentLines[5]);
    final scaleDegreeForOctave = int.parse(nonCommentLines[6]);

    final pattern = <int>[];
    for (int i = 0; i < mapSize; i++) {
      final lineIdx = 7 + i;
      if (lineIdx < nonCommentLines.length) {
        final keyStr = nonCommentLines[lineIdx];
        if (keyStr.toLowerCase() == 'x') {
          pattern.add(-1);
        } else {
          pattern.add(int.tryParse(keyStr) ?? i);
        }
      } else {
        pattern.add(i);
      }
    }

    return KeyboardMapping(
      mapSize: mapSize,
      firstMidiNote: firstMidi,
      lastMidiNote: lastMidi,
      middleMidiNote: middleMidi,
      referenceMidiNote: referenceMidi,
      referenceFrequency: referenceFreq,
      scaleDegreeForOctave: scaleDegreeForOctave,
      keyPattern: pattern,
    );
  }
}

class _CommentMetadata {
  const _CommentMetadata(this.key, this.value);
  final String key;
  final String value;
}
