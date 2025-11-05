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
  late State _currentState;
  final int gridSize;
  final Point<int> goal;
  final Random random = Random();

  GridWorld({
    this.gridSize = 4,
    Point<int>? goal,
  }) : goal = goal ?? Point(gridSize - 1, gridSize - 1) {
    _currentState = _createState(0, 0);
  }

  State _createState(int x, int y) => State(Point(x, y));

  Point<int> _getStateValue(State state) => state.value as Point<int>;

  @override
  State reset() {
    _currentState = _createState(0, 0);
    return _currentState;
  }

  @override
  State get currentState => _currentState;

  @override
  List<Action> get availableActions => getActionsForState(_currentState);

  @override
  List<Action> getActionsForState(State state) {
    final pos = _getStateValue(state);
    final actions = <Action>[];

    if (pos.x > 0) actions.add(Action('up'));
    if (pos.x < gridSize - 1) actions.add(Action('down'));
    if (pos.y > 0) actions.add(Action('left'));
    if (pos.y < gridSize - 1) actions.add(Action('right'));

    return actions;
  }

  @override
  List<State> get allStates {
    final states = <State>[];
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        states.add(_createState(x, y));
      }
    }
    return states;
  }

  @override
  List<Action> get allActions => [
        Action('up'),
        Action('down'),
        Action('left'),
        Action('right'),
      ];

  @override
  StepResult step(Action action) {
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
  bool get isTerminal => isStateTerminal(_currentState);

  @override
  bool isStateTerminal(State state) {
    final pos = _getStateValue(state);
    return pos.x == goal.x && pos.y == goal.y;
  }
}

/// Example demonstrating Q-Learning
void qLearningExample() {
  print('=== Q-Learning Example ===\n');

  final environment = GridWorld();
  final agent = QLearningAgent(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );

  print('Training Q-Learning agent for 1000 episodes...');
  agent.train(environment, 1000);

  print('\nQ-Table size: ${agent.qTableSize}');
  print('\nSample Q-values:');
  final sampleStates = [
    State(Point(0, 0)),
    State(Point(1, 1)),
    State(Point(2, 2)),
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
  final agent = SarsaAgent(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );

  print('Training SARSA agent for 1000 episodes...');
  agent.train(environment, 1000);

  print('\nQ-Table size: ${agent.qTableSize}');
  print('\nSample Q-values:');
  final sampleStates = [
    State(Point(0, 0)),
    State(Point(1, 1)),
    State(Point(2, 2)),
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
  final agent = ExpectedSarsaAgent(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );

  print('Training Expected-SARSA agent for 1000 episodes...');
  agent.train(environment, 1000);

  print('\nQ-Table size: ${agent.qTableSize}');
  print('\nSample Q-values:');
  final sampleStates = [
    State(Point(0, 0)),
    State(Point(1, 1)),
    State(Point(2, 2)),
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

  print('Comparing algorithms over $runs runs with $episodes episodes each...\n');

  // Q-Learning
  double qLearningAvgSteps = 0;
  for (int run = 0; run < runs; run++) {
    final env = GridWorld();
    final agent = QLearningAgent(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    agent.train(env, episodes);

    // Test
    env.reset();
    int steps = 0;
    agent.setEpsilon(0.0); // Greedy policy
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
    final agent = SarsaAgent(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    agent.train(env, episodes);

    // Test
    env.reset();
    int steps = 0;
    agent.setEpsilon(0.0); // Greedy policy
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
    final agent = ExpectedSarsaAgent(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    agent.train(env, episodes);

    // Test
    env.reset();
    int steps = 0;
    agent.setEpsilon(0.0); // Greedy policy
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
