import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_rl/dart_rl.dart';

/// Grid World environment for Flutter demo
class FlutterGridWorld implements Environment {
  late DartRlState _currentState;
  final int gridSize;
  final Point<int> goal;
  final Random random = Random();

  FlutterGridWorld({
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

    if (pos.x > 0) actions.add(const DartRlAction('up'));
    if (pos.x < gridSize - 1) actions.add(const DartRlAction('down'));
    if (pos.y > 0) actions.add(const DartRlAction('left'));
    if (pos.y < gridSize - 1) actions.add(const DartRlAction('right'));

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
  bool get isTerminal {
    final pos = _getStateValue(_currentState);
    return pos.x == goal.x && pos.y == goal.y;
  }
}

/// Simple training statistics
class TrainingStats {
  final int episode;
  final double totalReward;
  final int steps;
  final double epsilon;
  final int qTableSize;

  TrainingStats({
    required this.episode,
    required this.totalReward,
    required this.steps,
    required this.epsilon,
    required this.qTableSize,
  });
}

/// ChangeNotifier for managing RL training state
class RLTrainingNotifier extends ChangeNotifier {
  late final QLearning _agent;
  final FlutterGridWorld _environment;
  TrainingStats? _currentStats;
  bool _isTraining = false;
  int _currentEpisode = 0;
  int _totalEpisodes = 1000;
  double _episodeReward = 0.0;
  int _episodeSteps = 0;
  final List<double> _recentRewards = [];
  final List<int> _recentSteps = [];

  RLTrainingNotifier() : _environment = FlutterGridWorld() {
    _initialize();
  }

  void _initialize() {
    _agent = QLearning(
      learningRate: 0.1,
      discountFactor: 0.9,
      epsilon: 0.1,
    );
    _updateStats();
  }

  FlutterGridWorld get environment => _environment;
  TrainingStats? get currentStats => _currentStats;
  bool get isTraining => _isTraining;
  double get progress => _totalEpisodes > 0 ? _currentEpisode / _totalEpisodes : 0.0;
  double get averageReward => _recentRewards.isEmpty 
      ? 0.0 
      : _recentRewards.reduce((a, b) => a + b) / _recentRewards.length;
  double get averageSteps => _recentSteps.isEmpty 
      ? 0.0 
      : _recentSteps.reduce((a, b) => a + b) / _recentSteps.length;

  void _updateStats() {
    _currentStats = TrainingStats(
      episode: _currentEpisode,
      totalReward: _episodeReward,
      steps: _episodeSteps,
      epsilon: _agent.epsilon,
      qTableSize: _agent.qTable.length,
    );
  }

  Future<void> startTraining({int episodes = 1000}) async {
    if (_isTraining) return;

    _isTraining = true;
    _totalEpisodes = episodes;
    _currentEpisode = 0;
    _recentRewards.clear();
    _recentSteps.clear();
    notifyListeners();

    for (int i = 0; i < episodes; i++) {
      if (!_isTraining) break;

      _currentEpisode = i + 1;
      _episodeReward = 0.0;
      _episodeSteps = 0;

      // Train one episode and track stats
      _environment.reset();
      DartRlState state = _environment.currentState;

      while (!_environment.isTerminal) {
        final action = _agent.selectAction(_environment, state);
        final stepResult = _environment.step(action);
        final nextStateActions = _environment.getActionsForState(stepResult.nextState);

        // Update Q-value
        _agent.update(
          state,
          action,
          stepResult.reward,
          stepResult.nextState,
          nextStateActions,
        );

        _episodeReward += stepResult.reward;
        _episodeSteps++;
        state = stepResult.nextState;

        if (stepResult.isDone) break;
      }

      // Track recent performance
      _recentRewards.add(_episodeReward);
      _recentSteps.add(_episodeSteps);
      if (_recentRewards.length > 100) {
        _recentRewards.removeAt(0);
        _recentSteps.removeAt(0);
      }

      // Decay epsilon
      _agent.epsilon = (_agent.epsilon * 0.9995).clamp(0.01, 1.0);

      _updateStats();

      // Update UI periodically
      if (i % 10 == 0 || i == episodes - 1) {
        notifyListeners();
        // Allow UI to update
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
    _episodeReward = 0.0;
    _episodeSteps = 0;
    _updateStats();
    notifyListeners();
  }

  void takeStep() {
    if (_environment.isTerminal) {
      _environment.reset();
      _episodeReward = 0.0;
      _episodeSteps = 0;
    }

    final state = _environment.currentState;
    final originalEpsilon = _agent.epsilon;
    _agent.epsilon = 0.0; // Use greedy policy
    final action = _agent.selectAction(_environment, state);
    _agent.epsilon = originalEpsilon;
    
    final result = _environment.step(action);
    final nextStateActions = _environment.getActionsForState(result.nextState);

    // Update Q-value
    _agent.update(
      state,
      action,
      result.reward,
      result.nextState,
      nextStateActions,
    );

    _episodeSteps++;
    _episodeReward += result.reward;

    _updateStats();
    notifyListeners();
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
        final stats = notifier.currentStats;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Training Statistics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (notifier.isTraining)
                    Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Training...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (stats == null)
                const Expanded(
                  child: Center(
                    child: Text('No training data yet. Start training to see stats.'),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Episode',
                        value: '${stats.episode}',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Episode Reward',
                        value: stats.totalReward.toStringAsFixed(1),
                        color: stats.totalReward > 0 
                            ? Colors.green 
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Steps',
                        value: '${stats.steps}',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Avg Reward (100)',
                        value: notifier.averageReward.toStringAsFixed(1),
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Avg Steps (100)',
                        value: notifier.averageSteps.toStringAsFixed(1),
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Epsilon',
                        value: stats.epsilon.toStringAsFixed(3),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Q-Table Size',
                        value: '${stats.qTableSize}',
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _StatCard(
                        label: 'Progress',
                        value: '${(notifier.progress * 100).toStringAsFixed(1)}%',
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
                if (notifier.isTraining) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: notifier.progress.clamp(0.0, 1.0),
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ],
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
  final Color? color;

  const _StatCard({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Grid World (${env.gridSize}x${env.gridSize})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 16),
                  _LegendItem(
                    color: Colors.blue,
                    label: 'Agent',
                    icon: Icons.person,
                  ),
                  const SizedBox(width: 12),
                  _LegendItem(
                    color: Colors.green,
                    label: 'Goal',
                    icon: Icons.flag,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: env.gridSize,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: env.gridSize * env.gridSize,
                      itemBuilder: (context, index) {
                        // Convert index to grid coordinates
                        // Grid is displayed with x as row, y as column
                        final row = index ~/ env.gridSize;
                        final col = index % env.gridSize;
                        final pos = Point(row, col);
                        final isCurrent =
                            pos.x == currentPos.x && pos.y == currentPos.y;
                        final isGoal = pos.x == goal.x && pos.y == goal.y;

                        Color cellColor;
                        Widget? content;
                        
                        if (isGoal && isCurrent) {
                          // Agent reached goal
                          cellColor = Colors.green.shade700;
                          content = Stack(
                            alignment: Alignment.center,
                            children: const [
                              Icon(Icons.flag, color: Colors.white, size: 24),
                              Positioned(
                                bottom: 2,
                                child: Icon(Icons.person, 
                                    color: Colors.white, size: 16),
                              ),
                            ],
                          );
                        } else if (isGoal) {
                          cellColor = Colors.green.shade400;
                          content = const Icon(Icons.flag, 
                              color: Colors.white, size: 28);
                        } else if (isCurrent) {
                          cellColor = Colors.blue.shade400;
                          content = const Icon(Icons.person, 
                              color: Colors.white, size: 28);
                        } else {
                          cellColor = Colors.grey.shade200;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: cellColor,
                            border: Border.all(
                              color: Colors.grey.shade600,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isCurrent || isGoal
                                ? [
                                    BoxShadow(
                                      color: cellColor.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(child: content),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Legend item widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade600),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
        final isTraining = notifier.isTraining;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isTraining
                            ? null
                            : () async {
                                try {
                                  await notifier.startTraining(episodes: 1000);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Training error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Training'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isTraining
                            ? () {
                                notifier.stopTraining();
                              }
                            : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isTraining
                            ? null
                            : () {
                                notifier.resetEnvironment();
                              },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isTraining
                            ? null
                            : () {
                                try {
                                  notifier.takeStep();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Step error: $e'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Step'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
