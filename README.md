<div align="center">
  <img src="https://raw.githubusercontent.com/kekko7072/dart_rl/main/dart-rl-logo.png" alt="DartRL Logo" width="200"/>
  <h1>DartRL</h1>
</div>

A simple Dart package implementing reinforcement learning algorithms (Q-Learning, SARSA, Expected-SARSA).

## Features

- **Q-Learning**: Off-policy temporal difference learning algorithm
- **SARSA**: On-policy temporal difference learning algorithm  
- **Expected-SARSA**: On-policy algorithm using expected Q-values
- Clean, simple API for implementing custom environments
- Epsilon-greedy exploration strategy
- Support for discrete state and action spaces

## Installation

Add `dart_rl` to your `pubspec.yaml`:

```yaml
dependencies:
  dart_rl: ^0.2.0-alpha.3
```

Then run:

```bash
dart pub get
```

## Usage

### Basic Example

```dart
import 'package:dart_rl/dart_rl.dart';

// Create an environment (you need to implement the Environment interface)
final environment = GridWorld();

// Create a Q-Learning agent
final agent = QLearning(
  learningRate: 0.1,      // α (alpha)
  discountFactor: 0.9,    // γ (gamma)
  epsilon: 0.1,           // ε (epsilon) for exploration
);

// Train the agent
agent.train(environment, 1000);

// Use the learned policy
environment.reset();
final action = agent.selectAction(environment, environment.currentState);
final result = environment.step(action);
```

### Implementing a Custom Environment

To use `dart_rl` with your own environment, implement the `Environment` interface:

```dart
class MyEnvironment implements Environment {
  late DartRlState _currentState;

  @override
  DartRlState reset() {
    // Reset to initial state
    _currentState = DartRlState(initialValue);
    return _currentState;
  }

  @override
  DartRlState get currentState => _currentState;

  @override
  List<DartRlAction> getActionsForState(DartRlState state) {
    // Return available actions for the given state
    return [DartRlAction('action1'), DartRlAction('action2')];
  }

  @override
  StepResult step(DartRlAction action) {
    // Execute action and return result
    final nextState = DartRlState(newValue);
    _currentState = nextState;
    return StepResult(
      nextState: nextState,
      reward: rewardValue,
      isDone: isTerminal,
    );
  }

  @override
  bool get isTerminal {
    // Check if current state is terminal
    return /* terminal condition */;
  }
}
```

### Available Algorithms

#### Q-Learning

```dart
final agent = QLearning(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);

agent.train(environment, 1000);
```

#### SARSA

```dart
final agent = SARSA(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);

agent.train(environment, 1000);
```

#### Expected-SARSA

```dart
final agent = ExpectedSARSA(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);

agent.train(environment, 1000);
```

### Adjusting Exploration

You can control the exploration rate by modifying epsilon:

```dart
// Set epsilon to a specific value
agent.epsilon = 0.05;

// Use greedy policy (no exploration)
agent.epsilon = 0.0;
```

### Accessing Q-Values

```dart
// Get Q-value for a specific state-action pair
final qValue = agent.getQValue(DartRlState(stateValue), DartRlAction(actionValue));

// Get all Q-values for a state
final state = DartRlState(stateValue);
final qValues = agent.getQValuesForState(state);
for (final entry in qValues.entries) {
  print('${entry.key.value}: ${entry.value}');
}

// Access Q-table directly
final qTable = agent.qTable;
print('Q-table size: ${qTable.length}');
```

## Examples

### Dart Examples

See the `example/` directory for complete Dart examples:

- `grid_world/`: Simple grid world navigation demonstrating Q-Learning, SARSA, and Expected-SARSA
- `frozen_lake/`: Frozen lake environment with hazards using Expected-SARSA
- `flutter_rl_demo/`: Flutter application demonstrating the package

Run Dart examples:

```bash
# Grid World example
cd example/grid_world
dart pub get
dart run

# Frozen Lake example
cd example/frozen_lake
dart pub get
dart run
```

Or run from the root directory:

```bash
dart run example/grid_world/main.dart
dart run example/frozen_lake/main.dart
```

## Algorithm Details

### Q-Learning
- **Type**: Off-policy
- **Update Rule**: `Q(s,a) = Q(s,a) + α[r + γ * max(Q(s',a')) - Q(s,a)]`
- Learns the optimal policy regardless of the policy being followed

### SARSA
- **Type**: On-policy
- **Update Rule**: `Q(s,a) = Q(s,a) + α[r + γ * Q(s',a') - Q(s,a)]`
- Learns the value of the policy being followed

### Expected-SARSA
- **Type**: On-policy
- **Update Rule**: `Q(s,a) = Q(s,a) + α[r + γ * E[Q(s',a')] - Q(s,a)]`
- Uses expected Q-value over next actions, reducing variance compared to SARSA

## Parameters

- **learningRate (α)**: Controls how much new information overrides old information (0.0 to 1.0)
- **discountFactor (γ)**: Discount factor for future rewards (0.0 to 1.0)
- **epsilon (ε)**: Probability of exploration vs exploitation (0.0 to 1.0)

## API Reference

### Core Classes

- **`DartRlAgent`**: Base class for all RL agents with epsilon-greedy exploration
- **`QLearning`**: Off-policy Q-Learning implementation
- **`SARSA`**: On-policy SARSA implementation
- **`ExpectedSARSA`**: On-policy Expected-SARSA implementation
- **`Environment`**: Interface for implementing custom RL environments
- **`DartRlState`**: Represents a state in the environment
- **`DartRlAction`**: Represents an action that can be taken
- **`DartRlStateAction`**: Represents a state-action pair
- **`StepResult`**: Result of taking an action in the environment

## Requirements

- Dart SDK: `>=2.17.0 <4.0.0`

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
