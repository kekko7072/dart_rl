# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-XX

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
