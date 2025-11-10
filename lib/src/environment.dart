import 'state.dart';
import 'action.dart';

/// Represents the result of taking an action in an environment
class StepResult {
  final DartRlState nextState;
  final double reward;
  final bool isDone;

  const StepResult({
    required this.nextState,
    required this.reward,
    required this.isDone,
  });
}

/// Interface for reinforcement learning environments
abstract class Environment {
  /// Reset the environment to its initial state
  DartRlState reset();

  /// Get the current state of the environment
  DartRlState get currentState;

  /// Get all possible actions for the current state
  List<DartRlAction> getActionsForState(DartRlState state);

  /// Take a step in the environment with the given action
  StepResult step(DartRlAction action);

  /// Check if the current state is terminal
  bool get isTerminal;
}
