# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0-alpha.3] - 2025-11-10

### Added

- Documentation for `DartRlAction` constructor and `value` property
- Documentation for `DartRlState` constructor and `value` property
- Documentation for `DartRlAgent` constructor with parameter descriptions

### Changed

- **Example structure**: Restructured examples to follow Dart package layout guidelines
  - Moved `frozen_lake_example.dart` to `example/frozen_lake/main.dart` with its own `pubspec.yaml`
  - Moved `grid_world_example.dart` to `example/grid_world/main.dart` with its own `pubspec.yaml`
  - Each example now has its own subdirectory with `pubspec.yaml` that depends on the parent package
- Updated README.md to reflect new example structure and running instructions

## [0.2.0-alpha-1] - 2025-11-10

### Changed

- **Major refactor**: Simplified package to focus on pure Dart implementation
- Renamed `DartRLState` to `DartRlState` for consistent naming convention
- Renamed `DartRLAction` to `DartRlAction` for consistent naming convention
- Renamed `DartRLStateAction` to `DartRlStateAction` for consistent naming convention
- Split state and action classes into separate files (`state.dart`, `action.dart`, `state_action.dart`)
- Replaced Equatable-based equality with manual `operator ==` and `hashCode` implementations
- Updated package description to emphasize simplicity
- Simplified README with streamlined examples and documentation
- Updated version to 0.2.0-alpha.1

### Removed

- **Flutter SDK dependency**: Package is now pure Dart
- **Dependencies**: Removed `collection`, `equatable`, and `flutter` packages
- **Dev dependencies**: Removed `pedantic` package
- **Flutter integration**: Removed `AgentNotifier` and `trainStream` functionality
- **Flutter directory**: Removed entire `lib/src/flutter/` directory
- **Advanced features**: Removed `DecaySchedule`, `TrainingStats`, and `QTableSerializer` classes
- **Flutter-specific files**: Removed `agent_notifier.dart`, `agent_stream.dart`
- **Additional files**: Removed `decay_schedules.dart`, `serialization.dart`, `training_stats.dart`
- **Flutter documentation**: Removed Flutter integration sections from README
- **Flutter examples**: Removed `example/flutter_rl_demo/` directory

### Notes

This version represents a significant simplification of the package, focusing on core reinforcement learning algorithms for pure Dart applications. Flutter support and advanced features have been removed to reduce complexity and dependencies.

## [0.1.0-alpha.2] - 2025-11-10

### Added

- Flutter SDK dependency for seamless Flutter integration
- `collection` package (^1.17.0) for enhanced data structures
- `equatable` package (^2.0.5) for value equality in state and action classes
- `AgentNotifier` class: ChangeNotifier wrapper for Flutter state management integration
- `trainStream` extension method for reactive UI updates with stream-based training
- Decay schedules: `LinearDecaySchedule` and `ExponentialDecaySchedule` for epsilon decay
- `TrainingStats` class for tracking episode-level training metrics
- `AggregatedStats` class for computing statistics across multiple episodes
- `QTableSerializer` for saving and loading trained Q-tables to/from disk
- Comprehensive Flutter integration documentation in README with examples
- Complete Flutter demo app in `example/flutter_rl_demo/` with real-time visualization
- Examples for both stream-based training and ChangeNotifier pattern
- Documentation on decay schedules, training statistics, and model persistence

### Features

- Real-time training visualization for Flutter applications
- Stream-based training with reactive UI updates via `trainStream`
- Flutter state management integration through `AgentNotifier` (ChangeNotifier pattern)
- Compatible with Provider, Riverpod, and other Flutter state management solutions
- Configurable epsilon decay schedules (linear and exponential)
- Training statistics tracking with episode-level and aggregated metrics
- Q-table serialization for saving and loading trained agents
- Interactive Flutter example demonstrating real-time RL training visualization
- Support for training progress monitoring with episode, reward, steps, and epsilon tracking
- Non-blocking asynchronous training for smooth UI performance

### Changed

- Refactored `State` to `DartRLState` for improved naming consistency
- Refactored `Action` to `DartRLAction` for improved naming consistency
- Refactored `StateAction` to `DartRLStateAction` for improved naming consistency


## [0.1.0-alpha.1] - 2025-11-7

### Added

- Initial alpha release of dart_rl package
- Q-Learning algorithm implementation (`QLearningAgent`)
- SARSA algorithm implementation (`SarsaAgent`)
- Expected-SARSA algorithm implementation (`ExpectedSarsaAgent`)
- `Environment` interface for creating custom RL environments
- `Agent` base class with epsilon-greedy exploration strategy
- `State`, `Action`, and `StateAction` classes for representing RL components
- `StepResult` class for environment step results
- Grid World example environment
- Frozen Lake example environment
- Comprehensive unit tests
- Documentation and README with usage examples

### Features

- Support for discrete state and action spaces
- Configurable learning rate (α), discount factor (γ), and epsilon (ε)
- Epsilon-greedy exploration with decay functionality
- Q-table access for inspection and debugging
- Training methods for single episodes and multiple episodes
- Compatible with both Dart and Flutter applications

## [0.1.0] - 2025-11-1

### Added

- Initial release of dart_rl package
- Q-Learning algorithm implementation (`QLearningAgent`)
- SARSA algorithm implementation (`SarsaAgent`)
- Expected-SARSA algorithm implementation (`ExpectedSarsaAgent`)
- `Environment` interface for creating custom RL environments
- `Agent` base class with epsilon-greedy exploration strategy
- `State`, `Action`, and `StateAction` classes for representing RL components
- `StepResult` class for environment step results
- Grid World example environment
- Frozen Lake example environment
- Comprehensive unit tests
- Documentation and README with usage examples

### Features

- Support for discrete state and action spaces
- Configurable learning rate (?), discount factor (?), and epsilon (?)
- Epsilon-greedy exploration with decay functionality
- Q-table access for inspection and debugging
- Training methods for single episodes and multiple episodes
- Compatible with both Dart and Flutter applications
