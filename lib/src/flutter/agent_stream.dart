import 'dart:async';
import '../../dart_rl.dart';

/// Extension to add stream-based training for Flutter UI updates
extension AgentStreamExtension on Agent {
  /// Train the agent and emit training statistics as a stream
  ///
  /// This is useful for Flutter apps where you want to update the UI
  /// in real-time as the agent trains.
  ///
  /// Example:
  /// ```dart
  /// agent.trainStream(environment, episodes: 1000)
  ///   .listen((stats) {
  ///     print('Episode ${stats.episode}: Reward = ${stats.totalReward}');
  ///     // Update Flutter UI here
  ///   });
  /// ```
  Stream<TrainingStats> trainStream(
    Environment environment, {
    required int episodes,
    int reportInterval = 1,
    DecaySchedule? epsilonDecaySchedule,
  }) async* {
    final initialEpsilon = epsilon;

    for (int episode = 0; episode < episodes; episode++) {
      // Apply epsilon decay if provided
      if (epsilonDecaySchedule != null) {
        epsilon = epsilonDecaySchedule.getValue(
          episode,
          initialEpsilon,
          0.0,
        );
      }

      // Train one episode and collect stats
      final episodeStats = _trainEpisodeWithStats(environment, episode);

      // Yield stats at specified interval
      if (episode % reportInterval == 0 || episode == episodes - 1) {
        yield episodeStats;
      }
    }
  }

  /// Train a single episode and return statistics
  TrainingStats _trainEpisodeWithStats(Environment environment, int episode) {
    // Save initial epsilon for stats
    final initialEpsilon = epsilon;
    final initialLearningRate = learningRate;

    // Train the episode using the agent's trainEpisode method
    if (this is QLearningAgent) {
      (this as QLearningAgent).trainEpisode(environment);
    } else if (this is SarsaAgent) {
      (this as SarsaAgent).trainEpisode(environment);
    } else if (this is ExpectedSarsaAgent) {
      (this as ExpectedSarsaAgent).trainEpisode(environment);
    } else {
      // Fallback: manual episode training
      DartRLState state = environment.reset();
      while (!environment.isTerminal) {
        final action = selectAction(environment, state);
        final stepResult = environment.step(action);
        state = stepResult.nextState;
        if (stepResult.isDone) break;
      }
    }

    // Run a test episode to collect statistics
    environment.reset();
    double totalReward = 0.0;
    int steps = 0;

    while (!environment.isTerminal && steps < 1000) {
      final action = selectAction(environment, environment.currentState);
      final stepResult = environment.step(action);
      totalReward += stepResult.reward;
      steps++;
      if (stepResult.isDone) break;
    }

    // Calculate Q-table statistics
    double averageQValue = 0.0;
    double maxQValue = 0.0;
    int qTableSize = 0;

    if (this is QLearningAgent) {
      final qAgent = this as QLearningAgent;
      final qTable = qAgent.qTable;
      qTableSize = qTable.length;
      if (qTable.isNotEmpty) {
        final values = qTable.values.toList();
        averageQValue = values.reduce((a, b) => a + b) / values.length;
        maxQValue = values.reduce((a, b) => a > b ? a : b);
      }
    } else if (this is SarsaAgent) {
      final sarsaAgent = this as SarsaAgent;
      final qTable = sarsaAgent.qTable;
      qTableSize = qTable.length;
      if (qTable.isNotEmpty) {
        final values = qTable.values.toList();
        averageQValue = values.reduce((a, b) => a + b) / values.length;
        maxQValue = values.reduce((a, b) => a > b ? a : b);
      }
    } else if (this is ExpectedSarsaAgent) {
      final expectedSarsaAgent = this as ExpectedSarsaAgent;
      final qTable = expectedSarsaAgent.qTable;
      qTableSize = qTable.length;
      if (qTable.isNotEmpty) {
        final values = qTable.values.toList();
        averageQValue = values.reduce((a, b) => a + b) / values.length;
        maxQValue = values.reduce((a, b) => a > b ? a : b);
      }
    }

    return TrainingStats(
      episode: episode,
      totalReward: totalReward,
      steps: steps,
      epsilon: epsilon,
      learningRate: initialLearningRate,
      averageQValue: averageQValue,
      maxQValue: maxQValue,
      qTableSize: qTableSize,
    );
  }
}

/// Extension to add copyWith method to TrainingStats
extension TrainingStatsExtension on TrainingStats {
  TrainingStats copyWith({
    int? episode,
    double? totalReward,
    int? steps,
    double? epsilon,
    double? learningRate,
    double? averageQValue,
    double? maxQValue,
    int? qTableSize,
  }) {
    return TrainingStats(
      episode: episode ?? this.episode,
      totalReward: totalReward ?? this.totalReward,
      steps: steps ?? this.steps,
      epsilon: epsilon ?? this.epsilon,
      learningRate: learningRate ?? this.learningRate,
      averageQValue: averageQValue ?? this.averageQValue,
      maxQValue: maxQValue ?? this.maxQValue,
      qTableSize: qTableSize ?? this.qTableSize,
    );
  }
}
