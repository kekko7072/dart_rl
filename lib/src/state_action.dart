import 'package:equatable/equatable.dart';

/// Represents a state in the environment
class State extends Equatable {
  final dynamic value;

  const State(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'State($value)';
}

/// Represents an action that can be taken in the environment
class Action extends Equatable {
  final dynamic value;

  const Action(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Action($value)';
}

/// Represents a state-action pair
class StateAction extends Equatable {
  final State state;
  final Action action;

  const StateAction(this.state, this.action);

  @override
  List<Object?> get props => [state, action];

  @override
  String toString() => 'StateAction($state, $action)';
}
