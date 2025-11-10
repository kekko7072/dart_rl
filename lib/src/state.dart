/// Represents a state in the environment
class DartRlState {
  /// The value of this state
  final dynamic value;

  /// Creates a new [DartRlState] with the given [value]
  const DartRlState(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartRlState &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DartRlState($value)';
}
