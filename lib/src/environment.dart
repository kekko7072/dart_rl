import 'state_action.dart';

/// Represents the result of taking an action in an environment
class StepResult {
  final State nextState;
  final double reward;
  final bool isDone;

  const StepResult({
    required this.nextState,
    required this.reward,
    required this.isDone,
  });

  @override
  String toString() =>
      'StepResult(nextState: $nextState, reward: $reward, isDone: $isDone)';
}

/// Interface for reinforcement learning environments
abstract class Environment {
  /// Reset the environment to its initial state
  State reset();

  /// Get the current state of the environment
  State get currentState;

  /// Get all possible actions for the current state
  List<Action> get availableActions;

  /// Get all possible actions for a given state
  List<Action> getActionsForState(State state);

  /// Get all possible states in the environment
  List<State> get allStates;

  /// Get all possible actions in the environment
  List<Action> get allActions;

  /// Take a step in the environment with the given action
  StepResult step(Action action);

  /// Check if the current state is terminal
  bool get isTerminal;

  /// Check if a given state is terminal
  bool isStateTerminal(State state);
}
