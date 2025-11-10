import 'state.dart';
import 'action.dart';

/// Represents a state-action pair
class DartRlStateAction {
  final DartRlState state;
  final DartRlAction action;

  const DartRlStateAction(this.state, this.action);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartRlStateAction &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          action == other.action;

  @override
  int get hashCode => state.hashCode ^ action.hashCode;

  @override
  String toString() => 'DartRlStateAction($state, $action)';
}
