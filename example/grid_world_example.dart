import 'dart:math';
import 'package:dart_rl/dart_rl.dart';

/// Simple Grid World environment for testing RL algorithms
///
/// This is a 4x4 grid where:
/// - Agent starts at (0,0)
/// - Goal is at (3,3) with reward +10
/// - Each step has reward -1
/// - Episode ends when reaching goal
class GridWorld implements Environment {
  late DartRlState _currentState;
  final int gridSize;
  final Point<int> goal;

  GridWorld({
    this.gridSize = 4,
    Point<int>? goal,
  }) : goal = goal ?? Point(gridSize - 1, gridSize - 1) {
    _currentState = _createState(0, 0);
  }

  DartRlState _createState(int x, int y) => DartRlState(Point(x, y));

  Point<int> _getStateValue(DartRlState state) => state.value as Point<int>;

  @override
  DartRlState reset() {
    _currentState = _createState(0, 0);
    return _currentState;
  }

  @override
  DartRlState get currentState => _currentState;

  @override
  List<DartRlAction> getActionsForState(DartRlState state) {
    final pos = _getStateValue(state);
    final actions = <DartRlAction>[];

    if (pos.x > 0) actions.add(DartRlAction('up'));
    if (pos.x < gridSize - 1) actions.add(DartRlAction('down'));
    if (pos.y > 0) actions.add(DartRlAction('left'));
    if (pos.y < gridSize - 1) actions.add(DartRlAction('right'));

    return actions;
  }

  @override
  StepResult step(DartRlAction action) {
    final pos = _getStateValue(_currentState);
    final actionStr = action.value as String;

    int newX = pos.x;
    int newY = pos.y;

    switch (actionStr) {
      case 'up':
        newX = max(0, pos.x - 1);
        break;
      case 'down':
        newX = min(gridSize - 1, pos.x + 1);
        break;
      case 'left':
        newY = max(0, pos.y - 1);
        break;
      case 'right':
        newY = min(gridSize - 1, pos.y + 1);
        break;
    }

    final nextState = _createState(newX, newY);
    final nextPos = _getStateValue(nextState);

    double reward = -1.0; // Small negative reward for each step
    bool isDone = false;

    if (nextPos.x == goal.x && nextPos.y == goal.y) {
      reward = 10.0; // Large positive reward for reaching goal
      isDone = true;
    }

    _currentState = nextState;

    return StepResult(
      nextState: nextState,
      reward: reward,
      isDone: isDone,
    );
  }

  @override
  bool get isTerminal {
    final pos = _getStateValue(_currentState);
    return pos.x == goal.x && pos.y == goal.y;
  }
}

/// Example demonstrating Q-Learning
void qLearningExample() {
  print('=== Q-Learning Example ===\n');

  final environment = GridWorld();
  final agent = QLearning(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );

  print('Training Q-Learning agent for 1000 episodes...');
  agent.train(environment, 1000);

  print('\nQ-Table size: ${agent.qTable.length}');
  print('\nSample Q-values:');
  final sampleStates = [
    DartRlState(Point(0, 0)),
    DartRlState(Point(1, 1)),
    DartRlState(Point(2, 2)),
  ];

  for (final state in sampleStates) {
    final qValues = agent.getQValuesForState(state);
    print('  State $state:');
    for (final entry in qValues.entries) {
      print('    ${entry.key.value}: ${entry.value.toStringAsFixed(2)}');
    }
  }

  print('\nTesting policy...');
  environment.reset();
  int steps = 0;
  while (!environment.isTerminal && steps < 50) {
    final state = environment.currentState;
    final action = agent.selectAction(environment, state);
    final result = environment.step(action);
    print('  Step $steps: State=${state.value}, Action=${action.value}, '
        'Reward=${result.reward.toStringAsFixed(1)}, Done=${result.isDone}');
    steps++;
    if (result.isDone) break;
  }
  print('Reached goal in $steps steps!\n');
}

/// Example demonstrating SARSA
void sarsaExample() {
  print('=== SARSA Example ===\n');

  final environment = GridWorld();
  final agent = SARSA(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );

  print('Training SARSA agent for 1000 episodes...');
  agent.train(environment, 1000);

  print('\nQ-Table size: ${agent.qTable.length}');
  print('\nSample Q-values:');
  final sampleStates = [
    DartRlState(Point(0, 0)),
    DartRlState(Point(1, 1)),
    DartRlState(Point(2, 2)),
  ];

  for (final state in sampleStates) {
    final qValues = agent.getQValuesForState(state);
    print('  State $state:');
    for (final entry in qValues.entries) {
      print('    ${entry.key.value}: ${entry.value.toStringAsFixed(2)}');
    }
  }

  print('\nTesting policy...');
  environment.reset();
  int steps = 0;
  while (!environment.isTerminal && steps < 50) {
    final state = environment.currentState;
    final action = agent.selectAction(environment, state);
    final result = environment.step(action);
    print('  Step $steps: State=${state.value}, Action=${action.value}, '
        'Reward=${result.reward.toStringAsFixed(1)}, Done=${result.isDone}');
    steps++;
    if (result.isDone) break;
  }
  print('Reached goal in $steps steps!\n');
}

/// Example demonstrating Expected-SARSA
void expectedSarsaExample() {
  print('=== Expected-SARSA Example ===\n');

  final environment = GridWorld();
  final agent = ExpectedSARSA(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );

  print('Training Expected-SARSA agent for 1000 episodes...');
  agent.train(environment, 1000);

  print('\nQ-Table size: ${agent.qTable.length}');
  print('\nSample Q-values:');
  final sampleStates = [
    DartRlState(Point(0, 0)),
    DartRlState(Point(1, 1)),
    DartRlState(Point(2, 2)),
  ];

  for (final state in sampleStates) {
    final qValues = agent.getQValuesForState(state);
    print('  State $state:');
    for (final entry in qValues.entries) {
      print('    ${entry.key.value}: ${entry.value.toStringAsFixed(2)}');
    }
  }

  print('\nTesting policy...');
  environment.reset();
  int steps = 0;
  while (!environment.isTerminal && steps < 50) {
    final state = environment.currentState;
    final action = agent.selectAction(environment, state);
    final result = environment.step(action);
    print('  Step $steps: State=${state.value}, Action=${action.value}, '
        'Reward=${result.reward.toStringAsFixed(1)}, Done=${result.isDone}');
    steps++;
    if (result.isDone) break;
  }
  print('Reached goal in $steps steps!\n');
}

/// Example comparing all three algorithms
void compareAlgorithmsExample() {
  print('=== Algorithm Comparison ===\n');

  final episodes = 500;
  final runs = 5;

  print(
      'Comparing algorithms over $runs runs with $episodes episodes each...\n');

  // Q-Learning
  double qLearningAvgSteps = 0;
  for (int run = 0; run < runs; run++) {
    final env = GridWorld();
    final agent = QLearning(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    agent.train(env, episodes);

    // Test
    env.reset();
    agent.epsilon = 0.0; // Greedy policy
    int steps = 0;
    while (!env.isTerminal && steps < 50) {
      final action = agent.selectAction(env, env.currentState);
      final result = env.step(action);
      steps++;
      if (result.isDone) break;
    }
    qLearningAvgSteps += steps;
  }
  qLearningAvgSteps /= runs;

  // SARSA
  double sarsaAvgSteps = 0;
  for (int run = 0; run < runs; run++) {
    final env = GridWorld();
    final agent = SARSA(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    agent.train(env, episodes);

    // Test
    env.reset();
    agent.epsilon = 0.0; // Greedy policy
    int steps = 0;
    while (!env.isTerminal && steps < 50) {
      final action = agent.selectAction(env, env.currentState);
      final result = env.step(action);
      steps++;
      if (result.isDone) break;
    }
    sarsaAvgSteps += steps;
  }
  sarsaAvgSteps /= runs;

  // Expected-SARSA
  double expectedSarsaAvgSteps = 0;
  for (int run = 0; run < runs; run++) {
    final env = GridWorld();
    final agent = ExpectedSARSA(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    agent.train(env, episodes);

    // Test
    env.reset();
    agent.epsilon = 0.0; // Greedy policy
    int steps = 0;
    while (!env.isTerminal && steps < 50) {
      final action = agent.selectAction(env, env.currentState);
      final result = env.step(action);
      steps++;
      if (result.isDone) break;
    }
    expectedSarsaAvgSteps += steps;
  }
  expectedSarsaAvgSteps /= runs;

  print('Average steps to goal (lower is better):');
  print('  Q-Learning: ${qLearningAvgSteps.toStringAsFixed(1)}');
  print('  SARSA: ${sarsaAvgSteps.toStringAsFixed(1)}');
  print('  Expected-SARSA: ${expectedSarsaAvgSteps.toStringAsFixed(1)}\n');
}

void main() {
  qLearningExample();
  sarsaExample();
  expectedSarsaExample();
  compareAlgorithmsExample();
}
