import 'dart:math';
import 'environment.dart';
import 'state.dart';
import 'action.dart';

/// Base class for reinforcement learning agents
abstract class DartRlAgent {
  /// Learning rate (alpha)
  final double learningRate;

  /// Discount factor (gamma)
  final double discountFactor;

  /// Exploration rate (epsilon)
  double epsilon;

  /// Random number generator
  final Random random = Random();

  DartRlAgent({
    required this.learningRate,
    required this.discountFactor,
    required this.epsilon,
  });

  /// Select an action using epsilon-greedy policy
  DartRlAction selectAction(Environment environment, DartRlState state) {
    final availableActions = environment.getActionsForState(state);

    if (availableActions.isEmpty) {
      throw ArgumentError('No available actions for state $state');
    }

    // Epsilon-greedy: explore with probability epsilon, exploit otherwise
    if (random.nextDouble() < epsilon) {
      // Explore: choose random action
      return availableActions[random.nextInt(availableActions.length)];
    } else {
      // Exploit: choose best action according to Q-values
      return _selectBestAction(state, availableActions);
    }
  }

  /// Select the best action according to Q-values
  DartRlAction _selectBestAction(
      DartRlState state, List<DartRlAction> availableActions) {
    if (availableActions.isEmpty) {
      throw ArgumentError('No available actions');
    }

    // Get Q-values for all available actions
    double maxQ = getQValue(state, availableActions[0]);
    final bestActions = <DartRlAction>[availableActions[0]];

    for (int i = 1; i < availableActions.length; i++) {
      final qValue = getQValue(state, availableActions[i]);
      if (qValue > maxQ) {
        maxQ = qValue;
        bestActions.clear();
        bestActions.add(availableActions[i]);
      } else if (qValue == maxQ) {
        bestActions.add(availableActions[i]);
      }
    }

    // Return random action among best actions
    return bestActions[random.nextInt(bestActions.length)];
  }

  /// Get the Q-value for a state-action pair
  double getQValue(DartRlState state, DartRlAction action);

  /// Update the Q-value for a state-action pair
  void updateQValue(DartRlState state, DartRlAction action, double value);

  /// Get all Q-values for a given state
  Map<DartRlAction, double> getQValuesForState(DartRlState state) {
    final qValues = <DartRlAction, double>{};
    // This will be implemented by subclasses
    return qValues;
  }
}
