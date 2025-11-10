# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
