# dart_rl

A Dart package implementing reinforcement learning algorithms (SARSA, Q-Learning, Expected-SARSA) for both Dart and Flutter applications.

## Features

- **Q-Learning**: Off-policy temporal difference learning algorithm
- **SARSA**: On-policy temporal difference learning algorithm  
- **Expected-SARSA**: On-policy algorithm using expected Q-values
- Clean, extensible API for implementing custom environments
- Epsilon-greedy exploration strategy with configurable decay schedules
- Support for both discrete state and action spaces
- **Flutter Integration**: Stream-based training and ChangeNotifier wrappers for reactive UI updates
- **Real-time Visualization**: Built-in support for visualizing training progress in Flutter apps
- **Training Statistics**: Track and display training metrics in real-time with episode-level and aggregated statistics
- **Model Persistence**: Save and load trained Q-tables to/from disk
- **Multiple Decay Schedules**: Linear, Exponential, Polynomial, Step, and Cosine Annealing schedules for epsilon decay

## Installation

Add `dart_rl` to your `pubspec.yaml`:

```yaml
dependencies:
  dart_rl: ^0.1.0-alpha.2
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
  learningRate: 0.1,      // α (alpha)
  discountFactor: 0.9,    // γ (gamma)
  epsilon: 0.1,           // ε (epsilon) for exploration
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
  DartRLState reset() {
    // Reset to initial state
    return DartRLState(initialValue);
  }

  @override
  DartRLState get currentState => /* current state */;

  @override
  List<DartRLAction> getActionsForState(DartRLState state) {
    // Return available actions for the given state
    return [DartRLAction('action1'), DartRLAction('action2')];
  }

  @override
  StepResult step(DartRLAction action) {
    // Execute action and return result
    return StepResult(
      nextState: DartRLState(newValue),
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
final qValue = agent.getQValue(DartRLState(stateValue), DartRLAction(actionValue));

// Get all Q-values for a state
final state = DartRLState(stateValue);
final qValues = agent.getQValuesForState(state);
for (final entry in qValues.entries) {
  print('${entry.key}: ${entry.value}');
}

// Access Q-table directly (for QLearningAgent, SarsaAgent, ExpectedSarsaAgent)
if (agent is QLearningAgent) {
  final qTable = (agent as QLearningAgent).qTable;
  print('Q-table size: ${(agent as QLearningAgent).qTableSize}');
}
```

## Flutter Integration

`dart_rl` is designed to work seamlessly with Flutter applications. The package provides Flutter-specific APIs that make it easy to integrate RL training into your UI with real-time updates.

### Why Use RL in Flutter?

Reinforcement learning running locally in Flutter apps enables:

- **Interactive Learning**: Train agents in real-time while users interact with your app
- **Adaptive UI**: Create UIs that learn and adapt based on user behavior
- **Game AI**: Build intelligent game agents that learn from gameplay
- **Personalization**: Train models locally to personalize user experiences
- **Educational Apps**: Visualize RL algorithms in action for learning purposes
- **Offline AI**: Run AI agents entirely on-device without cloud dependencies

### Stream-Based Training (Reactive UI Updates)

Use the `trainStream` extension method to get real-time training statistics as a stream. This is perfect for updating Flutter widgets as training progresses:

```dart
import 'package:dart_rl/dart_rl.dart';
import 'package:flutter/material.dart';

class TrainingWidget extends StatefulWidget {
  @override
  _TrainingWidgetState createState() => _TrainingWidgetState();
}

class _TrainingWidgetState extends State<TrainingWidget> {
  final agent = QLearningAgent(
    learningRate: 0.1,
    discountFactor: 0.9,
    epsilon: 0.1,
  );
  final environment = GridWorld();
  
  TrainingStats? currentStats;
  StreamSubscription<TrainingStats>? _subscription;

  @override
  void initState() {
    super.initState();
    _startTraining();
  }

  void _startTraining() {
    final schedule = LinearDecaySchedule(
      totalSteps: 1000,
      minValue: 0.01,
    );
    
    _subscription = agent.trainStream(
      environment,
      episodes: 1000,
      reportInterval: 10,
      epsilonDecaySchedule: schedule,
    ).listen((stats) {
      setState(() {
        currentStats = stats;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentStats == null) {
      return CircularProgressIndicator();
    }
    
    return Column(
      children: [
        Text('Episode: ${currentStats!.episode}'),
        Text('Reward: ${currentStats!.totalReward.toStringAsFixed(2)}'),
        Text('Steps: ${currentStats!.steps}'),
        Text('Epsilon: ${currentStats!.epsilon.toStringAsFixed(3)}'),
      ],
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### Using AgentNotifier (ChangeNotifier Pattern)

For Flutter apps using Provider, Riverpod, or other state management solutions, use `AgentNotifier` which extends `ChangeNotifier`:

```dart
import 'package:dart_rl/dart_rl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RLTrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final agent = QLearningAgent(
          learningRate: 0.1,
          discountFactor: 0.9,
          epsilon: 0.1,
        );
        final env = GridWorld();
        return AgentNotifier(agent, env);
      },
      child: Scaffold(
        appBar: AppBar(title: Text('RL Training')),
        body: Consumer<AgentNotifier>(
          builder: (context, notifier, child) {
            final stats = notifier.currentStats;
            
            return Column(
              children: [
                if (stats != null) ...[
                  Text('Episode: ${stats.episode}'),
                  Text('Reward: ${stats.totalReward.toStringAsFixed(2)}'),
                  LinearProgressIndicator(value: notifier.progress),
                ],
                ElevatedButton(
                  onPressed: notifier.isTraining
                      ? null
                      : () => notifier.startTraining(episodes: 1000),
                  child: Text('Start Training'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

### Complete Flutter Example

A complete Flutter example app is available in `example/flutter_rl_demo/`. This example demonstrates:

- Real-time training visualization
- Interactive grid world environment
- Training statistics display
- Control buttons for training management

To run the Flutter example:

```bash
cd example/flutter_rl_demo
flutter pub get
flutter run
```

### Decay Schedules

Control how epsilon (exploration rate) decreases over time using decay schedules:

```dart
// Linear decay: decreases linearly from initial value to minValue over totalSteps
final linearSchedule = LinearDecaySchedule(
  totalSteps: 1000,
  minValue: 0.01,
);

// Exponential decay: decreases exponentially using decayRate
final expSchedule = ExponentialDecaySchedule(
  decayRate: 0.995,
  minValue: 0.01,
);

// Polynomial decay: decreases polynomially with configurable power
final polySchedule = PolynomialDecaySchedule(
  totalSteps: 1000,
  power: 2.0,  // Higher power = faster initial decay
  minValue: 0.01,
);

// Step decay: decreases by decayFactor every stepSize steps
final stepSchedule = StepDecaySchedule(
  stepSize: 100,      // Decay every 100 steps
  decayFactor: 0.9,   // Multiply by 0.9 each time
  minValue: 0.01,
);

// Cosine annealing: decreases following a cosine curve
final cosineSchedule = CosineAnnealingSchedule(
  totalSteps: 1000,
  minValue: 0.01,
);

// Use with trainStream
agent.trainStream(
  environment,
  episodes: 1000,
  epsilonDecaySchedule: linearSchedule,
).listen((stats) {
  // Update UI
});
```

### Training Statistics

Track training progress with `TrainingStats`:

```dart
final stats = TrainingStats(
  episode: 100,
  totalReward: 45.2,
  steps: 12,
  epsilon: 0.05,
  learningRate: 0.1,
  averageQValue: 2.3,
  maxQValue: 8.5,
  qTableSize: 64,
);
```

Aggregate statistics over multiple episodes:

```dart
final aggregated = AggregatedStats(episodes: allStats);
print('Average Reward: ${aggregated.averageReward}');
print('Best Reward: ${aggregated.bestReward}');
print('Worst Reward: ${aggregated.worstReward}');
print('Average Steps: ${aggregated.averageSteps}');
print('Reward Std Dev: ${aggregated.rewardStdDev}');

// Get statistics for specific episode ranges
final recentStats = aggregated.lastN(100);  // Last 100 episodes
final windowStats = aggregated.window(50, 150);  // Episodes 50-150
```

### Saving and Loading Q-Tables

Save trained agents to disk and load them later:

```dart
import 'package:dart_rl/dart_rl.dart';

// Save Q-table
final agent = QLearningAgent(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);
agent.train(environment, episodes: 1000);
await QTableSerializer.saveToFile('qtable.json', agent.qTable);

// Load Q-table
final loadedQTable = await QTableSerializer.loadFromFile('qtable.json');

// Reconstruct agent with loaded Q-table
final newAgent = QLearningAgent(
  learningRate: 0.1,
  discountFactor: 0.9,
  epsilon: 0.1,
);
// Manually populate Q-table (requires access to private _qTable)
// For custom state/action types, provide deserializers:
final customQTable = await QTableSerializer.loadFromFile(
  'qtable.json',
  stateDeserializer: (v) => DartRLState(/* custom deserialization */),
  actionDeserializer: (v) => DartRLAction(/* custom deserialization */),
);
```

## Examples

### Dart Examples

See the `example/` directory for complete Dart examples:

- `grid_world_example.dart`: Simple grid world navigation
- `frozen_lake_example.dart`: Frozen lake environment with hazards

Run Dart examples:

```bash
dart run example/grid_world_example.dart
dart run example/frozen_lake_example.dart
```

### Flutter Example

A complete Flutter app demonstrating RL training with real-time visualization:

- `example/flutter_rl_demo/`: Interactive Flutter app with:
  - Real-time training statistics
  - Grid world visualization
  - Interactive controls for training management
  - Progress indicators

Run Flutter example:

```bash
cd example/flutter_rl_demo
flutter pub get
flutter run
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

- **`Agent`**: Base class for all RL agents with epsilon-greedy exploration
- **`QLearningAgent`**: Off-policy Q-Learning implementation
- **`SarsaAgent`**: On-policy SARSA implementation
- **`ExpectedSarsaAgent`**: On-policy Expected-SARSA implementation
- **`Environment`**: Interface for implementing custom RL environments
- **`DartRLState`**: Represents a state in the environment
- **`DartRLAction`**: Represents an action that can be taken
- **`DartRLStateAction`**: Represents a state-action pair
- **`StepResult`**: Result of taking an action in the environment

### Flutter Integration

- **`AgentStreamExtension`**: Extension method adding `trainStream()` for reactive UI updates
- **`AgentNotifier`**: ChangeNotifier wrapper for Flutter state management (Provider, Riverpod, etc.)

### Utilities

- **`TrainingStats`**: Episode-level training statistics
- **`AggregatedStats`**: Aggregated statistics across multiple episodes
- **`DecaySchedule`**: Base class for epsilon decay schedules
  - `LinearDecaySchedule`: Linear decay over time
  - `ExponentialDecaySchedule`: Exponential decay
  - `PolynomialDecaySchedule`: Polynomial decay with configurable power
  - `StepDecaySchedule`: Step-wise decay at regular intervals
  - `CosineAnnealingSchedule`: Cosine annealing decay
- **`QTableSerializer`**: Utilities for saving/loading Q-tables to/from disk

## Requirements

- Dart SDK: `>=2.17.0 <4.0.0`
- Flutter SDK (for Flutter integration features)

## Dependencies

- `collection: ^1.17.0` - Enhanced data structures
- `equatable: ^2.0.5` - Value equality for state and action classes
- `flutter` (SDK) - For Flutter-specific features

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Links

- **Homepage**: https://github.com/kekko7072/dart_rl
- **Version**: 0.1.0-alpha.2
