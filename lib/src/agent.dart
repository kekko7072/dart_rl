import 'dart:math';
import 'package:collection/collection.dart';
import 'environment.dart';
import 'state_action.dart';

/// Base class for reinforcement learning agents
abstract class Agent {
  /// Learning rate (alpha)
  final double learningRate;

  /// Discount factor (gamma)
  final double discountFactor;

  /// Exploration rate (epsilon)
  double epsilon;

  /// Random number generator
  final Random random = Random();

  Agent({
    required this.learningRate,
    required this.discountFactor,
    required this.epsilon,
  });

  /// Select an action using epsilon-greedy policy
  Action selectAction(Environment environment, State state) {
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
  Action _selectBestAction(State state, List<Action> availableActions) {
    if (availableActions.isEmpty) {
      throw ArgumentError('No available actions');
    }

    // Get Q-values for all available actions
    final qValues = availableActions.map((action) {
      return QValue(state, action, getQValue(state, action));
    }).toList();

    // Find maximum Q-value
    final maxQValue = qValues.map((qv) => qv.value).max;

    // Get all actions with maximum Q-value (to break ties randomly)
    final bestActions = qValues
        .where((qv) => qv.value == maxQValue)
        .map((qv) => qv.action)
        .toList();

    // Return random action among best actions
    return bestActions[random.nextInt(bestActions.length)];
  }

  /// Get the Q-value for a state-action pair
  double getQValue(State state, Action action);

  /// Update the Q-value for a state-action pair
  void updateQValue(State state, Action action, double value);

  /// Get all Q-values for a given state
  Map<Action, double> getQValuesForState(State state);

  /// Decay epsilon (for epsilon-greedy exploration)
  void decayEpsilon(double decayRate) {
    epsilon = max(0.0, epsilon * decayRate);
  }

  /// Set epsilon to a specific value
  void setEpsilon(double value) {
    epsilon = value.clamp(0.0, 1.0);
  }
}

/// Helper class for Q-value comparisons
class QValue {
  final State state;
  final Action action;
  final double value;

  QValue(this.state, this.action, this.value);
}
