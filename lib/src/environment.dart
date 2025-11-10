import 'state_action.dart';

/// Represents the result of taking an action in an environment
class StepResult {
  final DartRLState nextState;
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
  DartRLState reset();

  /// Get the current state of the environment
  DartRLState get currentState;

  /// Get all possible actions for the current state
  List<DartRLAction> get availableActions;

  /// Get all possible actions for a given state
  List<DartRLAction> getActionsForState(DartRLState state);

  /// Get all possible states in the environment
  List<DartRLState> get allStates;

  /// Get all possible actions in the environment
  List<DartRLAction> get allActions;

  /// Take a step in the environment with the given action
  StepResult step(DartRLAction action);

  /// Check if the current state is terminal
  bool get isTerminal;

  /// Check if a given state is terminal
  bool isStateTerminal(DartRLState state);
}
