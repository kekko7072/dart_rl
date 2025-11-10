import 'package:equatable/equatable.dart';

/// Represents a state in the environment
class DartRLState extends Equatable {
  final dynamic value;

  const DartRLState(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'State($value)';
}

/// Represents an action that can be taken in the environment
class DartRLAction extends Equatable {
  final dynamic value;

  const DartRLAction(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Action($value)';
}

/// Represents a state-action pair
class DartRLStateAction extends Equatable {
  final DartRLState state;
  final DartRLAction action;

  const DartRLStateAction(this.state, this.action);

  @override
  List<Object?> get props => [state, action];

  @override
  String toString() => 'StateAction($state, $action)';
}
