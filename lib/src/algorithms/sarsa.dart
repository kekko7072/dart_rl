import '../agent.dart';
import '../environment.dart';
import '../state.dart';
import '../action.dart';
import '../state_action.dart';

/// SARSA algorithm implementation
///
/// SARSA (State-Action-Reward-State-Action) is an on-policy temporal difference
/// learning algorithm. It learns the action-value function Q for the policy being followed.
class SARSA extends DartRlAgent {
  /// Q-table: maps state-action pairs to Q-values
  final Map<DartRlStateAction, double> _qTable = {};

  /// Default Q-value for unseen state-action pairs
  final double defaultQValue;

  SARSA({
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

  /// Update Q-value using SARSA update rule
  ///
  /// Q(s,a) = Q(s,a) + α[r + γ * Q(s',a') - Q(s,a)]
  void update(
    DartRlState state,
    DartRlAction action,
    double reward,
    DartRlState nextState,
    DartRlAction nextAction,
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
    DartRlState state = environment.reset();

    // Select initial action
    DartRlAction action = selectAction(environment, state);

    while (!environment.isTerminal) {
      // Take step in environment
      final stepResult = environment.step(action);

      // Select next action using epsilon-greedy policy
      DartRlAction nextAction;
      if (stepResult.isDone || environment.isTerminal) {
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
  Map<DartRlStateAction, double> get qTable => Map.from(_qTable);
}
