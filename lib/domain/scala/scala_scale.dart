import 'package:equatable/equatable.dart';

import '../models/musical_note.dart';
import '../temperaments/rational_number.dart';
import '../tuning/tuning_math.dart';

/// Represents a single interval in a Scala scale definition.
///
/// An interval can be specified either as:
/// 1. A cent value (represented as a floating point number with a decimal point, e.g. 100.0)
/// 2. A rational fraction (represented as numerator/denominator, e.g. 3/2, 5/4)
/// 3. A pure integer ratio (e.g. 2, which represents 2/1)
class ScalaPitchInterval extends Equatable {
  const ScalaPitchInterval({
    required this.cents,
    this.rational,
    this.note,
    this.rawText = '',
  });

  /// Factory for a cents-based interval.
  factory ScalaPitchInterval.fromCents(
    double cents, {
    MusicalNote? note,
    String rawText = '',
  }) {
    return ScalaPitchInterval(
      cents: cents,
      rational: null,
      note: note,
      rawText: rawText,
    );
  }

  /// Factory for a rational ratio interval (e.g., 3/2).
  factory ScalaPitchInterval.fromRatio(
    int numerator,
    int denominator, {
    MusicalNote? note,
    String rawText = '',
  }) {
    final rational = RationalNumber(numerator, denominator);
    final ratioDouble = rational.toDouble();
    final cents = ratioDouble > 0 ? TuningMath.ratioToCents(ratioDouble) : 0.0;
    return ScalaPitchInterval(
      cents: cents,
      rational: rational,
      note: note,
      rawText: rawText,
    );
  }

  /// Factory for the unison root interval (0.0 cents, ratio 1/1).
  factory ScalaPitchInterval.unison({MusicalNote? note}) {
    return ScalaPitchInterval(
      cents: 0.0,
      rational: RationalNumber(1, 1),
      note: note,
      rawText: '1/1',
    );
  }

  /// Pitch interval value in cents (where 1200.0 is an octave).
  final double cents;

  /// Exact rational number representation if specified as a ratio; null if given as cents.
  final RationalNumber? rational;

  /// Associated musical note if annotated with `note=...`; null if unassigned.
  final MusicalNote? note;

  /// Original string representation from the Scala file line.
  final String rawText;

  /// Whether this interval was defined via an exact rational ratio.
  bool get isRatio => rational != null;

  /// Linear frequency multiplier relative to root (e.g. 2.0 for octave).
  double get ratio => rational?.toDouble() ?? TuningMath.centsToRatio(cents);

  @override
  List<Object?> get props => [cents, rational, note, rawText];

  @override
  String toString() {
    if (rational != null) {
      return '$rational (${cents.toStringAsFixed(2)}c)';
    }
    return '${cents.toStringAsFixed(2)}c';
  }
}

/// Represents an imported or synthesized Huygens-Fokker Scala (.scl) scale.
class ScalaScale extends Equatable {
  const ScalaScale({
    required this.name,
    this.abbreviation = '',
    this.description = '',
    this.version = '',
    required this.intervals,
    this.rootNote = const MusicalNote(base: BaseNote.c, octave: 4),
  });

  /// Human-readable name or title from the file.
  final String name;

  /// Short abbreviation (from `! abbreviation=...` comment).
  final String abbreviation;

  /// Detailed description (from first non-comment line or `! description=...`).
  final String description;

  /// Application version or exporter tag (from `! version=...`).
  final String version;

  /// List of intervals defining the scale degrees within the period (excluding root unison).
  ///
  /// According to the Scala specification, intervals does NOT include the root 0/0 (1/1 unison),
  /// but DOES include the formal octave/period interval at the end (usually 2/1 or 1200.0 cents).
  final List<ScalaPitchInterval> intervals;

  /// Default root note on which this scale is anchored.
  final MusicalNote rootNote;

  /// Number of notes/intervals per octave or period.
  int get count => intervals.length;

  /// The formal octave/period ratio of the scale (usually 2.0).
  double get periodRatio => intervals.isNotEmpty ? intervals.last.ratio : 2.0;

  /// The formal octave/period span in cents (usually 1200.0 cents).
  double get periodCents =>
      intervals.isNotEmpty ? intervals.last.cents : 1200.0;

  /// Returns full cents array across one octave, including root 0.0 at index 0.
  /// Length is strictly `count + 1`.
  List<double> get fullCents {
    final list = <double>[0.0];
    for (final interval in intervals) {
      list.add(interval.cents);
    }
    return list;
  }

  /// Returns full frequency multiplication ratios relative to root, including 1.0 at index 0.
  /// Length is strictly `count + 1`.
  List<double> get fullRatios {
    final list = <double>[1.0];
    for (final interval in intervals) {
      list.add(interval.ratio);
    }
    return list;
  }

  /// Returns full rational numbers list if every interval in the scale is a rational fraction,
  /// starting with 1/1 at index 0. Returns null if any interval was defined in cents.
  List<RationalNumber>? get fullRationalNumbers {
    final list = <RationalNumber>[RationalNumber(1, 1)];
    for (final interval in intervals) {
      if (interval.rational == null) return null;
      list.add(interval.rational!);
    }
    return list;
  }

  /// Returns all assigned musical notes across the scale degrees, or null if note names are incomplete.
  List<MusicalNote>? get noteNames {
    final notes = <MusicalNote>[];
    for (final interval in intervals) {
      if (interval.note != null) {
        notes.add(interval.note!);
      }
    }
    if (notes.length == count) return notes;
    return null;
  }

  /// Returns a copy with specified fields replaced.
  ScalaScale copyWith({
    String? name,
    String? abbreviation,
    String? description,
    String? version,
    List<ScalaPitchInterval>? intervals,
    MusicalNote? rootNote,
  }) {
    return ScalaScale(
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      description: description ?? this.description,
      version: version ?? this.version,
      intervals: intervals ?? this.intervals,
      rootNote: rootNote ?? this.rootNote,
    );
  }

  @override
  List<Object?> get props => [
    name,
    abbreviation,
    description,
    version,
    intervals,
    rootNote,
  ];
}
