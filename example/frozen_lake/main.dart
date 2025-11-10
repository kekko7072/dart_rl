import 'dart:io';
import 'dart:math';
import 'package:dart_rl/dart_rl.dart';

/// Frozen Lake environment (simplified version)
///
/// A grid world where:
/// - 'S' = Start (safe)
/// - 'F' = Frozen (safe)
/// - 'H' = Hole (episode ends, reward -10)
/// - 'G' = Goal (reward +10)
class FrozenLake implements Environment {
  final List<List<String>> grid;
  late DartRlState _currentState;
  final Random random = Random();

  FrozenLake({
    List<List<String>>? grid,
  }) : grid = grid ?? _defaultGrid() {
    _currentState = _findStartState();
  }

  static List<List<String>> _defaultGrid() {
    return [
      ['S', 'F', 'F', 'F'],
      ['F', 'H', 'F', 'H'],
      ['F', 'F', 'F', 'H'],
      ['H', 'F', 'F', 'G'],
    ];
  }

  DartRlState _createState(int row, int col) => DartRlState(Point(row, col));

  Point<int> _getStateValue(DartRlState state) => state.value as Point<int>;

  DartRlState _findStartState() {
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == 'S') {
          return _createState(i, j);
        }
      }
    }
    return _createState(0, 0);
  }

  @override
  DartRlState reset() {
    _currentState = _findStartState();
    return _currentState;
  }

  @override
  DartRlState get currentState => _currentState;

  @override
  List<DartRlAction> getActionsForState(DartRlState state) {
    return [
      DartRlAction('up'),
      DartRlAction('down'),
      DartRlAction('left'),
      DartRlAction('right'),
    ];
  }

  String _getCell(int row, int col) {
    if (row < 0 || row >= grid.length || col < 0 || col >= grid[row].length) {
      return 'W'; // Wall
    }
    return grid[row][col];
  }

  @override
  StepResult step(DartRlAction action) {
    final pos = _getStateValue(_currentState);
    final actionStr = action.value as String;

    int newRow = pos.x;
    int newCol = pos.y;

    switch (actionStr) {
      case 'up':
        newRow = max(0, pos.x - 1);
        break;
      case 'down':
        newRow = min(grid.length - 1, pos.x + 1);
        break;
      case 'left':
        newCol = max(0, pos.y - 1);
        break;
      case 'right':
        newCol = min(grid[0].length - 1, pos.y + 1);
        break;
    }

    final cell = _getCell(newRow, newCol);
    final nextState = _createState(newRow, newCol);

    double reward = -0.1; // Small negative reward for each step
    bool isDone = false;

    if (cell == 'H') {
      reward = -10.0;
      isDone = true;
    } else if (cell == 'G') {
      reward = 10.0;
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
    final cell = _getCell(pos.x, pos.y);
    return cell == 'H' || cell == 'G';
  }

  void printGrid() {
    final pos = _getStateValue(_currentState);
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (i == pos.x && j == pos.y) {
          stdout.write('A ');
        } else {
          stdout.write('${grid[i][j]} ');
        }
      }
      print('');
    }
  }
}

/// Example using Expected-SARSA on Frozen Lake
void main() {
  print('=== Frozen Lake with Expected-SARSA ===\n');

  final environment = FrozenLake();
  final agent = ExpectedSARSA(
    learningRate: 0.1,
    discountFactor: 0.95,
    epsilon: 0.2,
  );

  print('Training Expected-SARSA agent for 2000 episodes...');
  agent.train(environment, 2000);

  print('\nQ-Table size: ${agent.qTable.length}');

  print('\nTesting learned policy...');
  environment.reset();
  agent.epsilon = 0.0; // Greedy policy

  int steps = 0;
  double totalReward = 0;

  while (!environment.isTerminal && steps < 100) {
    final state = environment.currentState;
    final action = agent.selectAction(environment, state);
    final result = environment.step(action);

    print('\nStep $steps:');
    environment.printGrid();
    print('Action: ${action.value}');
    print('Reward: ${result.reward.toStringAsFixed(1)}');

    totalReward += result.reward;
    steps++;

    if (result.isDone) {
      print('\nEpisode finished!');
      print('Total reward: ${totalReward.toStringAsFixed(1)}');
      print('Steps taken: $steps');
      break;
    }
  }
}
