import 'dart:collection';
import '../agent.dart';
import '../environment.dart';
import '../state_action.dart';

/// Q-Learning algorithm implementation
/// 
/// Q-Learning is an off-policy temporal difference learning algorithm.
/// It learns the optimal action-value function Q* regardless of the policy being followed.
class QLearningAgent extends Agent {
  /// Q-table: maps state-action pairs to Q-values
  final Map<StateAction, double> _qTable = {};

  /// Default Q-value for unseen state-action pairs
  final double defaultQValue;

  QLearningAgent({
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

  /// Update Q-value using Q-Learning update rule
  /// 
  /// Q(s,a) = Q(s,a) + ?[r + ? * max(Q(s',a')) - Q(s,a)]
  void update(
    State state,
    Action action,
    double reward,
    State nextState,
    List<Action> nextStateActions,
  ) {
    final currentQ = getQValue(state, action);

    // Calculate max Q-value for next state
    double maxNextQ = 0.0;
    if (nextStateActions.isNotEmpty) {
      maxNextQ = nextStateActions
          .map((action) => getQValue(nextState, action))
          .reduce((a, b) => a > b ? a : b);
    }

    // Q-Learning update
    final newQ = currentQ +
        learningRate * (reward + discountFactor * maxNextQ - currentQ);

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

      // Update Q-value using Q-Learning
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
