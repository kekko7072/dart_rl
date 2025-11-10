/// Dart RL - Reinforcement Learning algorithms for Dart and Flutter
library dart_rl;

export 'src/environment.dart';
export 'src/agent.dart';
export 'src/algorithms/sarsa.dart';
export 'src/algorithms/q_learning.dart';
export 'src/algorithms/expected_sarsa.dart';
export 'src/state_action.dart';
export 'src/training_stats.dart';
export 'src/decay_schedules.dart';
export 'src/serialization.dart';

// Flutter-specific exports (only available when Flutter is available)
// These require Flutter to be available in the project
export 'src/flutter/agent_stream.dart';
export 'src/flutter/agent_notifier.dart';
