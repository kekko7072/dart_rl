import '../agent.dart';
import '../environment.dart';
import '../state.dart';
import '../action.dart';
import '../state_action.dart';

/// Q-Learning algorithm implementation
///
/// Q-Learning is an off-policy temporal difference learning algorithm.
/// It learns the optimal action-value function Q* regardless of the policy being followed.
class QLearning extends DartRlAgent {
  /// Q-table: maps state-action pairs to Q-values
  final Map<DartRlStateAction, double> _qTable = {};

  /// Default Q-value for unseen state-action pairs
  final double defaultQValue;

  QLearning({
    required super.learningRate,
    required super.discountFactor,
    required super.epsilon,
    this.defaultQValue = 0.0,
  });

  @override
  double getQValue(DartRlState state, DartRlAction action) {
    final key = DartRlStateAction(state, action);
    return _qTable[key] ?? defaultQValue;
  }

  @override
  void updateQValue(DartRlState state, DartRlAction action, double value) {
    final key = DartRlStateAction(state, action);
    _qTable[key] = value;
  }

  @override
  Map<DartRlAction, double> getQValuesForState(DartRlState state) {
    final qValues = <DartRlAction, double>{};
    for (final entry in _qTable.entries) {
      if (entry.key.state == state) {
        qValues[entry.key.action] = entry.value;
      }
    }
    return qValues;
  }

  /// Update Q-value using Q-Learning update rule
  ///
  /// Q(s,a) = Q(s,a) + α[r + γ * max(Q(s',a')) - Q(s,a)]
  void update(
    DartRlState state,
    DartRlAction action,
    double reward,
    DartRlState nextState,
    List<DartRlAction> nextStateActions,
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
    DartRlState state = environment.reset();

    while (!environment.isTerminal) {
      // Select action using epsilon-greedy policy
      final action = selectAction(environment, state);

      // Take step in environment
      final stepResult = environment.step(action);

      // Get available actions for next state
      final nextStateActions =
          environment.getActionsForState(stepResult.nextState);

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
  Map<DartRlStateAction, double> get qTable => Map.from(_qTable);
}
