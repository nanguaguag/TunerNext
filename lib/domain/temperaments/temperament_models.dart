import 'dart:math' as math;
import '../models/chain_of_fifths.dart';
import '../models/rational_number.dart';

/// Converts a frequency ratio to musical cents: 1200 * log2(ratio).
double ratioToCents(double ratio) {
  if (ratio <= 0.0) return 0.0;
  return 1200.0 * (math.log(ratio) / math.ln2);
}

/// Converts musical cents to frequency ratio: 2^(cents / 1200).
double centsToRatio(double cents) => math.pow(2.0, cents / 1200.0).toDouble();

/// Converts cents deviation to frequency relative to [referenceFrequency].
double centsToFrequency(double cents, double referenceFrequency) =>
    referenceFrequency * centsToRatio(cents);

/// Converts frequency to cents relative to [referenceFrequency].
double frequencyToCents(double frequency, double referenceFrequency) {
  if (referenceFrequency <= 0.0) return 0.0;
  return ratioToCents(frequency / referenceFrequency);
}

/// Base abstract definition of a musical temperament / tuning system.
abstract class Temperament {
  const Temperament();

  String get name;
  String get abbreviation;
  String get description;
  int get size;
  int get stableId;

  /// Returns cent values for all notes including the closing octave (size + 1 entries).
  List<double> cents();

  /// Returns exact rational number ratios relative to root note, or null if irrational/EDO.
  List<RationalNumber>? rationalNumbers() => null;

  /// Returns underlying chain-of-fifths structure if defined, or null otherwise.
  ChainOfFifths? chainOfFifths() => null;

  /// Returns equal octave divisions (EDO) if this scale is an EDO scale, or null otherwise.
  int? equalOctaveDivision() => null;
}

/// Equal Division of the Octave (EDO) temperament (e.g. 12-EDO, 19-EDO, 31-EDO, 72-EDO).
class TemperamentEDO extends Temperament {
  const TemperamentEDO({
    required this.notesPerOctave,
    required this.stableId,
    this.customName,
    this.customAbbr,
  });

  final int notesPerOctave;
  @override
  final int stableId;
  final String? customName;
  final String? customAbbr;

  @override
  String get name => customName ?? '$notesPerOctave-EDO';

  @override
  String get abbreviation => customAbbr ?? '$notesPerOctave-EDO';

  @override
  String get description =>
      'Equal division of the octave into $notesPerOctave intervals';

  @override
  int get size => notesPerOctave;

  @override
  int? equalOctaveDivision() => notesPerOctave;

  @override
  List<double> cents() {
    final step = 1200.0 / notesPerOctave;
    return List<double>.generate(notesPerOctave + 1, (i) => i * step);
  }
}

/// Historical temperament generated from a chain of fifths.
class TemperamentChainOfFifths extends Temperament {
  TemperamentChainOfFifths({
    required this.name,
    required this.abbreviation,
    required this.description,
    required this.fifthsChain,
    required this.stableId,
    this.uniqueIdentifier = '',
  });

  @override
  final String name;
  @override
  final String abbreviation;
  @override
  final String description;
  final ChainOfFifths fifthsChain;
  @override
  final int stableId;
  final String uniqueIdentifier;

  @override
  int get size => fifthsChain.fifths.length + 1;

  @override
  ChainOfFifths? chainOfFifths() => fifthsChain;

  @override
  List<double> cents() {
    final ratios = fifthsChain.getSortedRatios();
    final centList = ratios.map((r) => ratioToCents(r)).toList();
    centList.add(1200.0);
    return centList;
  }
}

/// Temperament defined via exact fractional rational ratios (e.g. Just Intonation).
class TemperamentRational extends Temperament {
  const TemperamentRational({
    required this.name,
    required this.abbreviation,
    required this.description,
    required this.ratios,
    required this.stableId,
    this.uniqueIdentifier = '',
  });

  @override
  final String name;
  @override
  final String abbreviation;
  @override
  final String description;
  final List<RationalNumber> ratios;
  @override
  final int stableId;
  final String uniqueIdentifier;

  @override
  int get size => ratios.length - 1;

  @override
  List<RationalNumber>? rationalNumbers() => ratios;

  @override
  List<double> cents() {
    return ratios.map((r) => ratioToCents(r.toDouble())).toList();
  }
}

/// Arbitrary user-defined or imported Scala temperament.
class TemperamentCustom extends Temperament {
  const TemperamentCustom({
    required this.name,
    required this.abbreviation,
    required this.description,
    required this.centValues,
    required this.stableId,
    this.ratioList,
    this.noteNamesList,
  });

  @override
  final String name;
  @override
  final String abbreviation;
  @override
  final String description;
  final List<double> centValues;
  @override
  final int stableId;
  final List<RationalNumber>? ratioList;
  final List<String>? noteNamesList;

  @override
  int get size => centValues.length - 1;

  @override
  List<double> cents() => centValues;

  @override
  List<RationalNumber>? rationalNumbers() => ratioList;
}
