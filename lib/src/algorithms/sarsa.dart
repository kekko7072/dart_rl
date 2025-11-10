import 'dart:collection';
import '../agent.dart';
import '../environment.dart';
import '../state_action.dart';

/// SARSA algorithm implementation
///
/// SARSA (State-Action-Reward-State-Action) is an on-policy temporal difference
/// learning algorithm. It learns the action-value function Q for the policy being followed.
class SarsaAgent extends Agent {
  /// Q-table: maps state-action pairs to Q-values
  final Map<DartRLStateAction, double> _qTable = {};

  /// Default Q-value for unseen state-action pairs
  final double defaultQValue;

  SarsaAgent({
    required super.learningRate,
    required super.discountFactor,
    required super.epsilon,
    this.defaultQValue = 0.0,
  });

  @override
  double getQValue(DartRLState state, DartRLAction action) {
    final key = DartRLStateAction(state, action);
    return _qTable[key] ?? defaultQValue;
  }

  @override
  void updateQValue(DartRLState state, DartRLAction action, double value) {
    final key = DartRLStateAction(state, action);
    _qTable[key] = value;
  }

  @override
  Map<DartRLAction, double> getQValuesForState(DartRLState state) {
    final qValues = <DartRLAction, double>{};
    for (final entry in _qTable.entries) {
      if (entry.key.state == state) {
        qValues[entry.key.action] = entry.value;
      }
    }
    return qValues;
  }

  /// Update Q-value using SARSA update rule
  ///
  /// Q(s,a) = Q(s,a) + ?[r + ? * Q(s',a') - Q(s,a)]
  void update(
    DartRLState state,
    DartRLAction action,
    double reward,
    DartRLState nextState,
    DartRLAction nextAction,
  ) {
    final currentQ = getQValue(state, action);
    final nextQ = getQValue(nextState, nextAction);

    // SARSA update
    final newQ =
        currentQ + learningRate * (reward + discountFactor * nextQ - currentQ);

    updateQValue(state, action, newQ);
  }

  /// Train the agent for one episode
  void trainEpisode(Environment environment) {
    DartRLState state = environment.reset();

    // Select initial action
    DartRLAction action = selectAction(environment, state);

    while (!environment.isTerminal) {
      // Take step in environment
      final stepResult = environment.step(action);

      // Select next action using epsilon-greedy policy
      DartRLAction nextAction;
      if (stepResult.isDone ||
          environment.isStateTerminal(stepResult.nextState)) {
        // Terminal state: next action is not used
        nextAction = action; // Dummy action, won't be used
      } else {
        nextAction = selectAction(environment, stepResult.nextState);
      }

      // Update Q-value using SARSA
      update(
        state,
        action,
        stepResult.reward,
        stepResult.nextState,
        nextAction,
      );

      state = stepResult.nextState;
      action = nextAction;

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
  Map<DartRLStateAction, double> get qTable => UnmodifiableMapView(_qTable);

  /// Get the number of state-action pairs in the Q-table
  int get qTableSize => _qTable.length;
}
