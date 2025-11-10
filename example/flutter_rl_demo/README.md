# Flutter RL Demo

A Flutter application demonstrating real-time reinforcement learning training with `dart_rl`.

## Features

- **Real-time Training Visualization**: Watch the agent learn in real-time as training progresses
- **Interactive Grid World**: Visualize the agent's position in a grid world environment
- **Training Statistics**: View episode number, rewards, steps, epsilon, and Q-table size
- **Training Controls**: Start, stop, reset, and step through training manually

## Getting Started

1. Make sure you have Flutter installed and configured
2. Navigate to this directory:
   ```bash
   cd example/flutter_rl_demo
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## How It Works

This demo uses `AgentNotifier` from `dart_rl` to provide reactive updates to Flutter widgets. The app:

1. Creates a Q-Learning agent and grid world environment
2. Wraps them in an `AgentNotifier` for Flutter state management
3. Uses `Provider` to share the notifier across widgets
4. Updates the UI in real-time as training progresses

## Key Components

- **RLTrainingNotifier**: Manages the agent and environment, provides training controls
- **TrainingStatsPanel**: Displays current training statistics
- **GridWorldVisualization**: Shows the grid world with agent and goal positions
- **ControlPanel**: Buttons to start, stop, reset, and step through training

## Customization

You can customize the training by modifying:

- Number of episodes: Change `episodes` parameter in `startTraining()`
- Learning rate, discount factor, epsilon: Modify agent creation in `RLTrainingNotifier`
- Grid size: Change `gridSize` in `FlutterGridWorld`
- Decay schedule: Modify the `LinearDecaySchedule` in `startTraining()`
