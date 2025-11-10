import 'dart:async';
import 'package:dart_rl/dart_rl.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../agent.dart';
import '../environment.dart';
import '../training_stats.dart';
import '../decay_schedules.dart';
import 'agent_stream.dart';

/// A ChangeNotifier wrapper for RL agents, making them Flutter-friendly
///
/// This class wraps an Agent and provides reactive updates for Flutter widgets.
/// Use this with Provider, Riverpod, or any state management solution that
/// works with ChangeNotifier.
///
/// Example:
/// ```dart
/// final agentNotifier = AgentNotifier(
///   QLearningAgent(
///     learningRate: 0.1,
///     discountFactor: 0.9,
///     epsilon: 0.1,
///   ),
/// );
///
/// // In your widget:
/// Consumer<AgentNotifier>(
///   builder: (context, notifier, child) {
///     return Text('Episode: ${notifier.currentEpisode}');
///   },
/// )
/// ```
class AgentNotifier extends ChangeNotifier {
  final Agent _agent;
  final Environment _environment;

  /// Current training statistics
  TrainingStats? _currentStats;

  /// All training statistics collected so far
  final List<TrainingStats> _allStats = [];

  /// Whether training is currently in progress
  bool _isTraining = false;

  /// Stream subscription for training updates
  StreamSubscription<TrainingStats>? _trainingSubscription;

  /// Current episode number
  int _currentEpisode = 0;

  /// Total episodes to train
  int _totalEpisodes = 0;

  AgentNotifier(this._agent, this._environment);

  /// The wrapped agent
  Agent get agent => _agent;

  /// The environment
  Environment get environment => _environment;

  /// Current training statistics
  TrainingStats? get currentStats => _currentStats;

  /// All collected training statistics
  List<TrainingStats> get allStats => List.unmodifiable(_allStats);

  /// Whether training is in progress
  bool get isTraining => _isTraining;

  /// Current episode number
  int get currentEpisode => _currentEpisode;

  /// Total episodes
  int get totalEpisodes => _totalEpisodes;

  /// Progress (0.0 to 1.0)
  double get progress {
    if (_totalEpisodes == 0) return 0.0;
    return _currentEpisode / _totalEpisodes;
  }

  /// Aggregated statistics
  AggregatedStats get aggregatedStats => AggregatedStats(episodes: _allStats);

  /// Start training the agent
  ///
  /// This will train the agent asynchronously and notify listeners
  /// as training progresses.
  Future<void> startTraining({
    required int episodes,
    int reportInterval = 1,
    DecaySchedule? epsilonDecaySchedule,
  }) async {
    if (_isTraining) {
      throw StateError('Training already in progress');
    }

    _isTraining = true;
    _totalEpisodes = episodes;
    _currentEpisode = 0;
    _allStats.clear();
    notifyListeners();

    try {
      _trainingSubscription = _agent
          .trainStream(
        _environment,
        episodes: episodes,
        reportInterval: reportInterval,
        epsilonDecaySchedule: epsilonDecaySchedule,
      )
          .listen(
        (stats) {
          _currentStats = stats;
          _currentEpisode = stats.episode;
          _allStats.add(stats);
          notifyListeners();
        },
        onDone: () {
          _isTraining = false;
          notifyListeners();
        },
        onError: (error) {
          _isTraining = false;
          notifyListeners();
          throw error;
        },
      );

      await _trainingSubscription?.asFuture();
    } finally {
      _isTraining = false;
      _trainingSubscription?.cancel();
      _trainingSubscription = null;
    }
  }

  /// Stop training
  void stopTraining() {
    _trainingSubscription?.cancel();
    _trainingSubscription = null;
    _isTraining = false;
    notifyListeners();
  }

  /// Reset the environment
  void resetEnvironment() {
    _environment.reset();
    notifyListeners();
  }

  /// Take a single step in the environment
  ///
  /// Returns the step result and updates the notifier
  StepResult takeStep() {
    final action = _agent.selectAction(_environment, _environment.currentState);
    final result = _environment.step(action);
    notifyListeners();
    return result;
  }

  /// Get Q-values for the current state
  Map<DartRLAction, double> getQValuesForCurrentState() {
    return _agent.getQValuesForState(_environment.currentState);
  }

  @override
  void dispose() {
    _trainingSubscription?.cancel();
    super.dispose();
  }
}
