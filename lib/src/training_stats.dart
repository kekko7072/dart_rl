/// Training statistics for tracking agent performance
class TrainingStats {
  /// Episode number
  final int episode;

  /// Total reward accumulated in this episode
  final double totalReward;

  /// Number of steps taken in this episode
  final int steps;

  /// Current epsilon value
  final double epsilon;

  /// Current learning rate
  final double learningRate;

  /// Average Q-value across all state-action pairs
  final double averageQValue;

  /// Maximum Q-value in the Q-table
  final double maxQValue;

  /// Number of state-action pairs in Q-table
  final int qTableSize;

  TrainingStats({
    required this.episode,
    required this.totalReward,
    required this.steps,
    required this.epsilon,
    required this.learningRate,
    required this.averageQValue,
    required this.maxQValue,
    required this.qTableSize,
  });

  @override
  String toString() {
    return 'TrainingStats(episode: $episode, reward: ${totalReward.toStringAsFixed(2)}, '
        'steps: $steps, epsilon: ${epsilon.toStringAsFixed(3)}, '
        'lr: ${learningRate.toStringAsFixed(3)}, qTableSize: $qTableSize)';
  }
}

/// Callback function type for training progress
typedef TrainingCallback = void Function(TrainingStats stats);

/// Aggregated statistics over multiple episodes
class AggregatedStats {
  /// List of episode statistics
  final List<TrainingStats> episodes;

  /// Average reward over all episodes
  double get averageReward {
    if (episodes.isEmpty) return 0.0;
    return episodes.map((e) => e.totalReward).reduce((a, b) => a + b) / episodes.length;
  }

  /// Average steps per episode
  double get averageSteps {
    if (episodes.isEmpty) return 0.0;
    return episodes.map((e) => e.steps).reduce((a, b) => a + b) / episodes.length;
  }

  /// Best reward achieved
  double get bestReward {
    if (episodes.isEmpty) return 0.0;
    return episodes.map((e) => e.totalReward).reduce((a, b) => a > b ? a : b);
  }

  /// Worst reward achieved
  double get worstReward {
    if (episodes.isEmpty) return 0.0;
    return episodes.map((e) => e.totalReward).reduce((a, b) => a < b ? a : b);
  }

  /// Standard deviation of rewards
  double get rewardStdDev {
    if (episodes.isEmpty) return 0.0;
    final avg = averageReward;
    final variance = episodes
        .map((e) => (e.totalReward - avg) * (e.totalReward - avg))
        .reduce((a, b) => a + b) /
        episodes.length;
    return variance > 0 ? variance : 0.0;
  }

  /// Get statistics for the last N episodes
  AggregatedStats lastN(int n) {
    if (n >= episodes.length) return this;
    return AggregatedStats(episodes: episodes.sublist(episodes.length - n));
  }

  /// Get statistics for a window of episodes
  AggregatedStats window(int start, int end) {
    if (start < 0 || end > episodes.length || start >= end) {
      return AggregatedStats(episodes: []);
    }
    return AggregatedStats(episodes: episodes.sublist(start, end));
  }

  AggregatedStats({required this.episodes});

  @override
  String toString() {
    if (episodes.isEmpty) return 'AggregatedStats(no episodes)';
    return 'AggregatedStats(episodes: ${episodes.length}, '
        'avgReward: ${averageReward.toStringAsFixed(2)}, '
        'avgSteps: ${averageSteps.toStringAsFixed(1)}, '
        'best: ${bestReward.toStringAsFixed(2)}, '
        'worst: ${worstReward.toStringAsFixed(2)})';
  }
}
