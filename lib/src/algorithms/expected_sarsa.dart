import 'dart:collection';
import '../agent.dart';
import '../environment.dart';
import '../state_action.dart';

/// Expected-SARSA algorithm implementation
/// 
/// Expected-SARSA is an on-policy temporal difference learning algorithm.
/// Instead of using the Q-value of the next action (like SARSA), it uses
/// the expected value of Q over all possible next actions according to the policy.
class ExpectedSarsaAgent extends Agent {
  /// Q-table: maps state-action pairs to Q-values
  final Map<StateAction, double> _qTable = {};

  /// Default Q-value for unseen state-action pairs
  final double defaultQValue;

  ExpectedSarsaAgent({
    required super.learningRate,
    required super.discountFactor,
    required super.epsilon,
    this.defaultQValue = 0.0,
  });

  @override
  double getQValue(State state, Action action) {
    final key = StateAction(state, action);
    return _qTable[key] ?? defaultQValue;
  }

  @override
  void updateQValue(State state, Action action, double value) {
    final key = StateAction(state, action);
    _qTable[key] = value;
  }

  @override
  Map<Action, double> getQValuesForState(State state) {
    final qValues = <Action, double>{};
    for (final entry in _qTable.entries) {
      if (entry.key.state == state) {
        qValues[entry.key.action] = entry.value;
      }
    }
    return qValues;
  }

  /// Calculate the expected Q-value for the next state under the current policy
  double _calculateExpectedQValue(State nextState, List<Action> availableActions) {
    if (availableActions.isEmpty) {
      return 0.0;
    }

    // Get Q-values for all available actions
    final qValues = availableActions.map((action) => getQValue(nextState, action)).toList();
    final maxQValue = qValues.reduce((a, b) => a > b ? a : b);

    // Calculate probabilities for each action using epsilon-greedy policy
    final numActions = availableActions.length;
    final probBest = (1 - epsilon) + (epsilon / numActions);
    final probOther = epsilon / numActions;

    // Calculate expected value
    double expectedValue = 0.0;
    for (int i = 0; i < availableActions.length; i++) {
      final qValue = qValues[i];
      final probability = (qValue == maxQValue) ? probBest : probOther;
      expectedValue += probability * qValue;
    }

    return expectedValue;
  }

  /// Update Q-value using Expected-SARSA update rule
  /// 
  /// Q(s,a) = Q(s,a) + ?[r + ? * E[Q(s',a')] - Q(s,a)]
  void update(
    State state,
    Action action,
    double reward,
    State nextState,
    List<Action> nextStateActions,
  ) {
    final currentQ = getQValue(state, action);

    // Calculate expected Q-value for next state
    final expectedNextQ = _calculateExpectedQValue(nextState, nextStateActions);

    // Expected-SARSA update
    final newQ = currentQ +
        learningRate * (reward + discountFactor * expectedNextQ - currentQ);

    updateQValue(state, action, newQ);
  }

  /// Train the agent for one episode
  void trainEpisode(Environment environment) {
    State state = environment.reset();

    while (!environment.isTerminal) {
      // Select action using epsilon-greedy policy
      final action = selectAction(environment, state);

      // Take step in environment
      final stepResult = environment.step(action);

      // Get available actions for next state
      final nextStateActions = environment.getActionsForState(stepResult.nextState);

      // Update Q-value using Expected-SARSA
      update(
        state,
        action,
        stepResult.reward,
        stepResult.nextState,
        nextStateActions,
      );

      state = stepResult.nextState;

      if (stepResult.isDone) {
        break;
      }
    }
  }

  /// Train the agent for multiple episodes
  void train(Environment environment, int episodes) {
    for (int i = 0; i < episodes; i++) {
      trainEpisode(environment);
    }
  }

  /// Get a copy of the Q-table
  Map<StateAction, double> get qTable => UnmodifiableMapView(_qTable);

  /// Get the number of state-action pairs in the Q-table
  int get qTableSize => _qTable.length;
}
