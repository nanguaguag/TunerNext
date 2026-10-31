import '../models/musical_note.dart';
import 'instrument.dart';
import 'instrument_icon.dart';

/// File validation status for imported instrument lists.
enum InstrumentFileCheck { ok, empty, invalid }

/// Result of parsing an instrument export string or file.
class InstrumentParseResult {
  const InstrumentParseResult({
    required this.status,
    required this.instruments,
    this.version,
    this.errors = const [],
  });

  final InstrumentFileCheck status;
  final List<Instrument> instruments;
  final String? version;
  final List<String> errors;

  bool get isOk => status == InstrumentFileCheck.ok;
  bool get isEmpty => status == InstrumentFileCheck.empty;
  bool get isInvalid => status == InstrumentFileCheck.invalid;
}

/// Serializer and parser for instruments import/export files.
///
/// Fully compatible with the Android Tuner `InstrumentIO` text format.
class InstrumentIO {
  InstrumentIO._();

  static const String _versionPrefix = 'Version=';
  static const String _instrumentPrefix = 'Instrument ';
  static const String _lengthPrefix = 'Length of name=';
  static const String _namePrefix = 'Name=';
  static const String _iconPrefix = 'Icon=';
  static const String _stringsPrefix = 'Strings=';

  /// Serializes a list of instruments to string.
  static String instrumentsListToString(
    List<Instrument> instruments, {
    String version = '2.0.0',
  }) {
    final buffer = StringBuffer();
    buffer.write('$_versionPrefix$version\n\n');

    for (int i = 0; i < instruments.length; i++) {
      if (i > 0) buffer.write('\n\n');
      buffer.write(_singleInstrumentToString(instruments[i]));
    }

    return buffer.toString();
  }

  static String _singleInstrumentToString(Instrument instrument) {
    final name = instrument.name;
    final buffer = StringBuffer();
    buffer.writeln('$_instrumentPrefix${instrument.stableId}');
    buffer.writeln('$_lengthPrefix${name.length}');
    buffer.writeln('$_namePrefix$name');
    buffer.writeln('$_iconPrefix${instrument.icon.serializedName}');

    buffer.write('$_stringsPrefix[');
    for (int i = 0; i < instrument.strings.length; i++) {
      if (i > 0) buffer.write(';');
      buffer.write(_noteToString(instrument.strings[i]));
    }
    buffer.write(']\n');

    return buffer.toString();
  }

  static String _noteToString(MusicalNote note) {
    final buffer = StringBuffer();
    buffer.write('MusicalNote(base=${note.base.name.toUpperCase()}');
    buffer.write(',modifier=${_modifierToKotlinName(note.modifier)}');
    buffer.write(',octave=${note.octave}');

    if (note.enharmonicBase != null) {
      buffer.write(
        ',enharmonicBase=${note.enharmonicBase!.name.toUpperCase()}',
      );
      buffer.write(
        ',enharmonicModifier=${_modifierToKotlinName(note.enharmonicModifier ?? NoteModifier.none)}',
      );
      buffer.write(',enharmonicOctave=${note.octave}');
    }

    buffer.write(')');
    return buffer.toString();
  }

  static String _modifierToKotlinName(NoteModifier modifier) {
    switch (modifier) {
      case NoteModifier.sharp:
        return 'Sharp';
      case NoteModifier.flat:
        return 'Flat';
      case NoteModifier.doubleSharp:
        return 'SharpSharp';
      case NoteModifier.doubleFlat:
        return 'FlatFlat';
      case NoteModifier.none:
        return 'None';
    }
  }

  /// Parses an instruments export string.
  static InstrumentParseResult stringToInstruments(String content) {
    if (content.trim().isEmpty) {
      return const InstrumentParseResult(
        status: InstrumentFileCheck.empty,
        instruments: [],
      );
    }

    final sanitized = content.startsWith('\uFEFF')
        ? content.substring(1)
        : content;

    final stream = _SimpleStream(sanitized);
    final instruments = <Instrument>[];
    final errors = <String>[];

    String? version;
    int nameLength = -1;
    String instrumentName = '';
    List<MusicalNote>? strings;
    InstrumentIcon icon = InstrumentIcon.guitar;
    int stableId = Instrument.noStableId;
    bool hasMalformedStrings = false;
    int instrumentsRead = 0;

    while (!stream.isEos()) {
      stream.advanceWhitespace();
      if (stream.isEos()) break;

      final lineRemaining = stream.peekLine();

      if (lineRemaining.startsWith(_versionPrefix)) {
        stream.advance(_versionPrefix.length);
        version = stream.readLine().trim();
      } else if (lineRemaining.startsWith(_instrumentPrefix)) {
        // Finalize previous instrument if one was in progress
        if (strings != null) {
          instruments.add(
            Instrument(
              name: instrumentName,
              strings: strings,
              icon: icon,
              stableId: stableId,
            ),
          );
          instrumentsRead++;
        }

        stream.advance(_instrumentPrefix.length);
        final idStr = stream.readLine().trim();
        stableId = int.tryParse(idStr) ?? Instrument.noStableId;
        nameLength = -1;
        instrumentName = '';
        strings = null;
        icon = InstrumentIcon.guitar;
      } else if (lineRemaining.startsWith(_lengthPrefix)) {
        stream.advance(_lengthPrefix.length);
        nameLength = int.tryParse(stream.readLine().trim()) ?? -1;
      } else if (lineRemaining.startsWith(_namePrefix)) {
        stream.advance(_namePrefix.length);
        if (nameLength >= 0) {
          instrumentName = stream.readExactChars(nameLength);
          // Consume any trailing newline after the exact name
          stream.skipNewline();
        } else {
          instrumentName = stream.readLine();
        }
      } else if (lineRemaining.startsWith(_iconPrefix)) {
        stream.advance(_iconPrefix.length);
        final iconStr = stream.readLine().trim();
        icon = InstrumentIcon.fromString(iconStr);
      } else if (lineRemaining.startsWith(_stringsPrefix)) {
        stream.advance(_stringsPrefix.length);
        final rawArray = stream.readLine().trim();
        final parsed = _parseMusicalNoteArray(rawArray);
        if (parsed == null) {
          hasMalformedStrings = true;
          errors.add('Malformed strings array: $rawArray');
        } else {
          strings = parsed;
        }
      } else {
        // Unknown or empty line, skip to next line
        stream.goToNextLine();
      }
    }

    // Process trailing instrument
    if (strings != null) {
      instruments.add(
        Instrument(
          name: instrumentName,
          strings: strings,
          icon: icon,
          stableId: stableId,
        ),
      );
      instrumentsRead++;
    }

    if (hasMalformedStrings || (version == null && instrumentsRead == 0)) {
      return InstrumentParseResult(
        status: InstrumentFileCheck.invalid,
        instruments: const [],
        version: version,
        errors: errors,
      );
    }

    return InstrumentParseResult(
      status: InstrumentFileCheck.ok,
      instruments: List.unmodifiable(instruments),
      version: version,
    );
  }

  static List<MusicalNote>? _parseMusicalNoteArray(String text) {
    if (!text.startsWith('[') || !text.endsWith(']')) {
      return null;
    }

    final inner = text.substring(1, text.length - 1).trim();
    if (inner.isEmpty) {
      return const [];
    }

    final parts = inner.split(';');
    final result = <MusicalNote>[];

    for (final part in parts) {
      final note = _parseSingleMusicalNote(part.trim());
      if (note == null) return null;
      result.add(note);
    }

    return result;
  }

  static MusicalNote? _parseSingleMusicalNote(String string) {
    if (!string.startsWith('MusicalNote(') || !string.endsWith(')')) {
      return null;
    }

    final body = string.substring('MusicalNote('.length, string.length - 1);
    final pairs = body.split(',');
    final map = <String, String>{};

    for (final p in pairs) {
      final kv = p.split('=');
      if (kv.length == 2) {
        map[kv[0].trim()] = kv[1].trim();
      }
    }

    final baseStr = map['base'];
    if (baseStr == null) return null;

    final base = _stringToBaseNote(baseStr);
    if (base == null) return null;

    final modifierStr = map['modifier'] ?? 'None';
    final modifier = _stringToModifier(modifierStr);

    final octave = int.tryParse(map['octave'] ?? '4') ?? 4;

    BaseNote? enharmonicBase;
    NoteModifier? enharmonicModifier;

    if (map.containsKey('enharmonicBase')) {
      enharmonicBase = _stringToBaseNote(map['enharmonicBase']!);
      if (map.containsKey('enharmonicModifier')) {
        enharmonicModifier = _stringToModifier(map['enharmonicModifier']!);
      }
    }

    return MusicalNote(
      base: base,
      modifier: modifier,
      octave: octave,
      enharmonicBase: enharmonicBase,
      enharmonicModifier: enharmonicModifier,
    );
  }

  static BaseNote? _stringToBaseNote(String str) {
    switch (str.toUpperCase()) {
      case 'C':
        return BaseNote.c;
      case 'D':
        return BaseNote.d;
      case 'E':
        return BaseNote.e;
      case 'F':
        return BaseNote.f;
      case 'G':
        return BaseNote.g;
      case 'A':
        return BaseNote.a;
      case 'B':
        return BaseNote.b;
      default:
        return null;
    }
  }

  static NoteModifier _stringToModifier(String str) {
    switch (str.toLowerCase()) {
      case 'sharp':
      case '#':
        return NoteModifier.sharp;
      case 'flat':
      case 'b':
        return NoteModifier.flat;
      case 'sharpsharp':
      case 'doublesharp':
      case '##':
        return NoteModifier.doubleSharp;
      case 'flatflat':
      case 'doubleflat':
      case 'bb':
        return NoteModifier.doubleFlat;
      default:
        return NoteModifier.none;
    }
  }
}

class _SimpleStream {
  _SimpleStream(this.string);
  final String string;
  int pos = 0;

  bool isEos() => pos >= string.length;

  void advance([int count = 1]) {
    pos = (pos + count).clamp(0, string.length);
  }

  void advanceWhitespace() {
    while (pos < string.length && _isWhitespace(string.codeUnitAt(pos))) {
      pos++;
    }
  }

  void goToNextLine() {
    while (pos < string.length && string[pos] != '\n') {
      pos++;
    }
    if (pos < string.length) pos++;
  }

  void skipNewline() {
    if (pos < string.length && string[pos] == '\r') pos++;
    if (pos < string.length && string[pos] == '\n') pos++;
  }

  String peekLine() {
    int end = pos;
    while (end < string.length && string[end] != '\n' && string[end] != '\r') {
      end++;
    }
    return string.substring(pos, end);
  }

  String readLine() {
    int end = pos;
    while (end < string.length && string[end] != '\n' && string[end] != '\r') {
      end++;
    }
    final result = string.substring(pos, end);
    pos = end;
    skipNewline();
    return result;
  }

  String readExactChars(int count) {
    final end = (pos + count).clamp(0, string.length);
    final result = string.substring(pos, end);
    pos = end;
    return result;
  }

  static bool _isWhitespace(int codeUnit) {
    return codeUnit == 32 || codeUnit == 9 || codeUnit == 10 || codeUnit == 13;
  }
}
