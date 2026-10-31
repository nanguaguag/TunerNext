/// Predefined visual icons for instruments and tunings.
///
/// Icon names are matched with standard material vectors or assets in UI layers,
/// and names are serialized to persistence/export files.
enum InstrumentIcon {
  guitar,
  ukulele,
  eguitar,
  bass,
  violin,
  cello,
  doubleBass,
  trumpet,
  saxophone,
  flute,
  harp,
  tar,
  setar,
  kamancheh,
  piano;

  /// Parses an icon from string name (case-insensitive, supporting underscores and spaces).
  static InstrumentIcon fromString(String name) {
    final sanitized = name.trim().toLowerCase().replaceAll(' ', '_');
    for (final icon in InstrumentIcon.values) {
      if (icon.name.toLowerCase() == sanitized ||
          icon.serializedName.toLowerCase() == sanitized) {
        return icon;
      }
    }
    return InstrumentIcon.guitar;
  }

  /// Name string compatible with Kotlin Tuner storage (e.g. "double_bass").
  String get serializedName {
    switch (this) {
      case InstrumentIcon.doubleBass:
        return 'double_bass';
      default:
        return name;
    }
  }
}
