import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_rl/dart_rl.dart';

/// Grid World environment for Flutter demo
class FlutterGridWorld implements Environment {
  late DartRLState _currentState;
  final int gridSize;
  final Point<int> goal;
  final Random random = Random();

  FlutterGridWorld({
    this.gridSize = 4,
    Point<int>? goal,
  }) : goal = goal ?? Point(gridSize - 1, gridSize - 1) {
    _currentState = _createState(0, 0);
  }

  DartRLState _createState(int x, int y) => DartRLState(Point(x, y));

  Point<int> _getStateValue(DartRLState state) => state.value as Point<int>;

  @override
  DartRLState reset() {
    _currentState = _createState(0, 0);
    return _currentState;
  }

  @override
  DartRLState get currentState => _currentState;

  @override
  List<DartRLAction> get availableActions => getActionsForState(_currentState);

  @override
  List<DartRLAction> getActionsForState(DartRLState state) {
    final pos = _getStateValue(state);
    final actions = <DartRLAction>[];

    if (pos.x > 0) actions.add(DartRLAction('up'));
    if (pos.x < gridSize - 1) actions.add(DartRLAction('down'));
    if (pos.y > 0) actions.add(DartRLAction('left'));
    if (pos.y < gridSize - 1) actions.add(DartRLAction('right'));

    return actions;
  }

  @override
  List<DartRLState> get allStates {
    final states = <DartRLState>[];
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        states.add(_createState(x, y));
      }
    }
    return states;
  }

  @override
  List<DartRLAction> get allActions => [
        DartRLAction('up'),
        DartRLAction('down'),
        DartRLAction('left'),
        DartRLAction('right'),
      ];

  @override
  StepResult step(DartRLAction action) {
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

    double reward = -1.0;
    bool isDone = false;

    if (nextPos.x == goal.x && nextPos.y == goal.y) {
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
  bool get isTerminal => isStateTerminal(_currentState);

  @override
  bool isStateTerminal(DartRLState state) {
    final pos = _getStateValue(state);
    return pos.x == goal.x && pos.y == goal.y;
  }
}

/// ChangeNotifier for managing RL training state
class RLTrainingNotifier extends ChangeNotifier {
  late final AgentNotifier _agentNotifier;
  final FlutterGridWorld _environment;

  bool _isInitialized = false;

  RLTrainingNotifier() : _environment = FlutterGridWorld() {
    _initialize();
  }

  void _initialize() {
    final agent = QLearningAgent(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    _agentNotifier = AgentNotifier(agent, _environment);
    _agentNotifier.addListener(() => notifyListeners());
    _isInitialized = true;
  }

  AgentNotifier get agentNotifier => _agentNotifier;
  FlutterGridWorld get environment => _environment;
  bool get isInitialized => _isInitialized;

  Future<void> startTraining({int episodes = 1000}) async {
    final schedule = LinearDecaySchedule(
      totalSteps: episodes,
      minValue: 0.01,
    );
    await _agentNotifier.startTraining(
      episodes: episodes,
      reportInterval: 10,
      epsilonDecaySchedule: schedule,
    );
  }

  void stopTraining() {
    _agentNotifier.stopTraining();
  }

  void resetEnvironment() {
    _agentNotifier.resetEnvironment();
  }

  void takeStep() {
    _agentNotifier.takeStep();
  }

  @override
  void dispose() {
    _agentNotifier.dispose();
    super.dispose();
  }
}

/// Main training page widget
class RLTrainingPage extends StatelessWidget {
  const RLTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RLTrainingNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dart RL - Flutter Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Column(
          children: [
            Expanded(
              flex: 2,
              child: TrainingStatsPanel(),
            ),
            Expanded(
              flex: 3,
              child: GridWorldVisualization(),
            ),
            Expanded(
              flex: 1,
              child: ControlPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel showing training statistics
class TrainingStatsPanel extends StatelessWidget {
  const TrainingStatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RLTrainingNotifier>(
      builder: (context, notifier, child) {
        final stats = notifier.agentNotifier.currentStats;
        final agentNotifier = notifier.agentNotifier;

        if (stats == null) {
          return const Center(
            child: Text('No training data yet. Start training to see stats.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Training Statistics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Episode',
                      value: '${stats.episode}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Total Reward',
                      value: stats.totalReward.toStringAsFixed(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Steps',
                      value: '${stats.steps}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Epsilon',
                      value: stats.epsilon.toStringAsFixed(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Q-Table Size',
                      value: '${stats.qTableSize}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Progress',
                      value:
                          '${(agentNotifier.progress * 100).toStringAsFixed(1)}%',
                    ),
                  ),
                ],
              ),
              if (agentNotifier.isTraining) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: agentNotifier.progress,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid world visualization widget
class GridWorldVisualization extends StatelessWidget {
  const GridWorldVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RLTrainingNotifier>(
      builder: (context, notifier, child) {
        final env = notifier.environment;
        final currentState = env.currentState;
        final currentPos = currentState.value as Point<int>;
        final goal = Point(env.gridSize - 1, env.gridSize - 1);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Grid World (${env.gridSize}x${env.gridSize})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: env.gridSize,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: env.gridSize * env.gridSize,
                  itemBuilder: (context, index) {
                    final x = index ~/ env.gridSize;
                    final y = index % env.gridSize;
                    final pos = Point(x, y);
                    final isCurrent =
                        pos.x == currentPos.x && pos.y == currentPos.y;
                    final isGoal = pos.x == goal.x && pos.y == goal.y;

                    Color color;
                    if (isGoal) {
                      color = Colors.green;
                    } else if (isCurrent) {
                      color = Colors.blue;
                    } else {
                      color = Colors.grey.shade300;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: isCurrent
                            ? const Icon(Icons.person, color: Colors.white)
                            : isGoal
                                ? const Icon(Icons.flag, color: Colors.white)
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Control panel widget
class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RLTrainingNotifier>(
      builder: (context, notifier, child) {
        final agentNotifier = notifier.agentNotifier;
        final isTraining = agentNotifier.isTraining;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isTraining
                    ? null
                    : () async {
                        await notifier.startTraining(episodes: 1000);
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Training'),
              ),
              ElevatedButton.icon(
                onPressed: isTraining
                    ? () {
                        notifier.stopTraining();
                      }
                    : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Training'),
              ),
              ElevatedButton.icon(
                onPressed: isTraining
                    ? null
                    : () {
                        notifier.resetEnvironment();
                      },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              ElevatedButton.icon(
                onPressed: isTraining
                    ? null
                    : () {
                        notifier.takeStep();
                      },
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
