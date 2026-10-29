/// Discrete states of tuning accuracy evaluated against tolerance bounds.
enum TuningState {
  /// Pitch matches the target within specified cents tolerance.
  inTune,

  /// Pitch is flat (too low, needs tightening).
  tooLow,

  /// Pitch is sharp (too high, needs loosening).
  tooHigh,

  /// No valid pitch detected or signal is silent.
  unknown,
}
