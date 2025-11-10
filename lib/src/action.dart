/// Represents an action that can be taken in the environment
class DartRlAction {
  /// The value of this action
  final dynamic value;

  /// Creates a new [DartRlAction] with the given [value]
  const DartRlAction(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartRlAction &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'DartRlAction($value)';
}
