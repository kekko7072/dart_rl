import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_rl/dart_rl.dart';

/// Simple Grid World environment
class FlutterGridWorld implements Environment {
  late DartRlState _currentState;
  final int gridSize = 4;
  final Point<int> goal = const Point(3, 3);

  FlutterGridWorld() {
    _currentState = DartRlState(const Point(0, 0));
  }

  Point<int> _getPos(DartRlState state) => state.value as Point<int>;

  @override
  DartRlState reset() {
    _currentState = DartRlState(const Point(0, 0));
    return _currentState;
  }

  @override
  DartRlState get currentState => _currentState;

  @override
  List<DartRlAction> getActionsForState(DartRlState state) {
    final pos = _getPos(state);
    final actions = <DartRlAction>[];
    if (pos.x > 0) actions.add(const DartRlAction('up'));
    if (pos.x < gridSize - 1) actions.add(const DartRlAction('down'));
    if (pos.y > 0) actions.add(const DartRlAction('left'));
    if (pos.y < gridSize - 1) actions.add(const DartRlAction('right'));
    return actions;
  }

  @override
  StepResult step(DartRlAction action) {
    final pos = _getPos(_currentState);
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

    final nextState = DartRlState(Point(newX, newY));
    final nextPos = _getPos(nextState);
    final isDone = nextPos.x == goal.x && nextPos.y == goal.y;
    _currentState = nextState;

    return StepResult(
      nextState: nextState,
      reward: isDone ? 10.0 : -1.0,
      isDone: isDone,
    );
  }

  @override
  bool get isTerminal {
    final pos = _getPos(_currentState);
    return pos.x == goal.x && pos.y == goal.y;
  }
}

/// Training state manager
class RLTrainingNotifier extends ChangeNotifier {
  final QLearning _agent = QLearning(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );
  final FlutterGridWorld _environment = FlutterGridWorld();
  
  bool _isTraining = false;
  int _episode = 0;
  double _reward = 0.0;
  int _steps = 0;

  FlutterGridWorld get environment => _environment;
  bool get isTraining => _isTraining;
  int get episode => _episode;
  double get reward => _reward;
  int get steps => _steps;
  double get epsilon => _agent.epsilon;

  Future<void> startTraining({int episodes = 1000}) async {
    if (_isTraining) return;
    _isTraining = true;
    notifyListeners();

    for (int i = 0; i < episodes && _isTraining; i++) {
      _episode = i + 1;
      _reward = 0.0;
      _steps = 0;
      _environment.reset();
      var state = _environment.currentState;

      while (!_environment.isTerminal) {
        final action = _agent.selectAction(_environment, state);
        final result = _environment.step(action);
        _agent.update(
          state,
          action,
          result.reward,
          result.nextState,
          _environment.getActionsForState(result.nextState),
        );
        _reward += result.reward;
        _steps++;
        state = result.nextState;
        if (result.isDone) break;
      }

      _agent.epsilon = (_agent.epsilon * 0.9995).clamp(0.01, 1.0);
      
      if (i % 10 == 0 || i == episodes - 1) {
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    _isTraining = false;
    notifyListeners();
  }

  void stopTraining() {
    _isTraining = false;
    notifyListeners();
  }

  void resetEnvironment() {
    _environment.reset();
    _reward = 0.0;
    _steps = 0;
    notifyListeners();
  }

  void takeStep() {
    if (_environment.isTerminal) {
      resetEnvironment();
      return;
    }

    final state = _environment.currentState;
    final oldEpsilon = _agent.epsilon;
    _agent.epsilon = 0.0;
    final action = _agent.selectAction(_environment, state);
    _agent.epsilon = oldEpsilon;
    
    final result = _environment.step(action);
    _agent.update(
      state,
      action,
      result.reward,
      result.nextState,
      _environment.getActionsForState(result.nextState),
    );
    _reward += result.reward;
    _steps++;
    notifyListeners();
  }
}

/// Main page
class RLTrainingPage extends StatelessWidget {
  const RLTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RLTrainingNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dart RL Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          children: [
            Expanded(child: _StatsPanel()),
            Expanded(flex: 2, child: _GridVisualization()),
            _ControlPanel(),
          ],
        ),
      ),
    );
  }
}

/// Stats display
class _StatsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RLTrainingNotifier>(
      builder: (context, notifier, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (notifier.isTraining)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Training...'),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat('Episode', '${notifier.episode}'),
                  _Stat('Reward', notifier.reward.toStringAsFixed(1)),
                  _Stat('Steps', '${notifier.steps}'),
                  _Stat('Epsilon', notifier.epsilon.toStringAsFixed(2)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

/// Grid visualization
class _GridVisualization extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RLTrainingNotifier>(
      builder: (context, notifier, _) {
        final env = notifier.environment;
        final pos = env.currentState.value as Point<int>;
        final goal = const Point(3, 3);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              final row = index ~/ 4;
              final col = index % 4;
              final cellPos = Point(row, col);
              final isAgent = pos.x == cellPos.x && pos.y == cellPos.y;
              final isGoal = goal.x == cellPos.x && goal.y == cellPos.y;

              Color color;
              Widget? icon;

              if (isGoal && isAgent) {
                color = Colors.green.shade700;
                icon = const Icon(Icons.flag, color: Colors.white);
              } else if (isGoal) {
                color = Colors.green.shade400;
                icon = const Icon(Icons.flag, color: Colors.white);
              } else if (isAgent) {
                color = Colors.blue.shade400;
                icon = const Icon(Icons.person, color: Colors.white);
              } else {
                color = Colors.grey.shade200;
              }

              return Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey.shade600),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(child: icon),
              );
            },
          ),
        );
      },
    );
  }
}

/// Control buttons
class _ControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RLTrainingNotifier>(
      builder: (context, notifier, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: notifier.isTraining
                    ? null
                    : () => notifier.startTraining(episodes: 1000),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Train'),
              ),
              ElevatedButton.icon(
                onPressed: notifier.isTraining
                    ? () => notifier.stopTraining()
                    : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: notifier.isTraining ? null : notifier.resetEnvironment,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              OutlinedButton.icon(
                onPressed: notifier.isTraining ? null : notifier.takeStep,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Step'),
              ),
            ],
          ),
        );
      },
    );
  }
}
