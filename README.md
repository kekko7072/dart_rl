# dart_rl

A Dart package implementing reinforcement learning algorithms (SARSA, Q-Learning, Expected-SARSA) for both Dart and Flutter applications.

## Features

- **Q-Learning**: Off-policy temporal difference learning algorithm
- **SARSA**: On-policy temporal difference learning algorithm  
- **Expected-SARSA**: On-policy algorithm using expected Q-values
- Clean, extensible API for implementing custom environments
- Epsilon-greedy exploration strategy
- Support for both discrete state and action spaces

## Installation

Add `dart_rl` to your `pubspec.yaml`:

```yaml
dependencies:
  dart_rl: ^0.1.0
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
final agent = QLearningAgent(
  learningRate: 0.1,      // ? (alpha)
  discountFactor: 0.9,    // ? (gamma)
  epsilon: 0.1,           // ? (epsilon) for exploration
);

// Train the agent
agent.train(environment, episodes: 1000);

// Use the learned policy
environment.reset();
final action = agent.selectAction(environment, environment.currentState);
final result = environment.step(action);
```

### Implementing a Custom Environment

To use `dart_rl` with your own environment, implement the `Environment` interface:

```dart
class MyEnvironment implements Environment {
  @override
  State reset() {
    // Reset to initial state
    return State(initialValue);
  }

  @override
  State get currentState => /* current state */;

  @override
  List<Action> getActionsForState(State state) {
    // Return available actions for the given state
    return [Action('action1'), Action('action2')];
  }

  @override
  StepResult step(Action action) {
    // Execute action and return result
    return StepResult(
      nextState: State(newValue),
      reward: rewardValue,
      isDone: isTerminal,
    );
  }

  // ... implement other required methods
}
```

### Available Algorithms

#### Q-Learning

```dart
final agent = QLearningAgent(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);

agent.train(environment, episodes: 1000);
```

#### SARSA

```dart
final agent = SarsaAgent(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);

agent.train(environment, episodes: 1000);
```

#### Expected-SARSA

```dart
final agent = ExpectedSarsaAgent(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);

agent.train(environment, episodes: 1000);
```

### Adjusting Exploration

You can control the exploration rate:

```dart
// Set epsilon to a specific value
agent.setEpsilon(0.05);

// Decay epsilon over time
agent.decayEpsilon(0.99); // Multiply epsilon by 0.99

// Use greedy policy (no exploration)
agent.setEpsilon(0.0);
```

### Accessing Q-Values

```dart
// Get Q-value for a specific state-action pair
final qValue = agent.getQValue(state, action);

// Get all Q-values for a state
final qValues = agent.getQValuesForState(state);
for (final entry in qValues.entries) {
  print('${entry.key}: ${entry.value}');
}
```

## Examples

See the `example/` directory for complete examples:

- `grid_world_example.dart`: Simple grid world navigation
- `frozen_lake_example.dart`: Frozen lake environment with hazards

Run examples:

```bash
dart run example/grid_world_example.dart
dart run example/frozen_lake_example.dart
```

## Algorithm Details

### Q-Learning
- **Type**: Off-policy
- **Update Rule**: `Q(s,a) = Q(s,a) + ?[r + ? * max(Q(s',a')) - Q(s,a)]`
- Learns the optimal policy regardless of the policy being followed

### SARSA
- **Type**: On-policy
- **Update Rule**: `Q(s,a) = Q(s,a) + ?[r + ? * Q(s',a') - Q(s,a)]`
- Learns the value of the policy being followed

### Expected-SARSA
- **Type**: On-policy
- **Update Rule**: `Q(s,a) = Q(s,a) + ?[r + ? * E[Q(s',a')] - Q(s,a)]`
- Uses expected Q-value over next actions, reducing variance compared to SARSA

## Parameters

- **learningRate (?)**: Controls how much new information overrides old information (0.0 to 1.0)
- **discountFactor (?)**: Discount factor for future rewards (0.0 to 1.0)
- **epsilon (?)**: Probability of exploration vs exploitation (0.0 to 1.0)

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
# dart_rl
