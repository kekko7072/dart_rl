import 'dart:math';
import 'package:test/test.dart';
import 'package:dart_rl/dart_rl.dart';

import '../example/grid_world_example.dart';

void main() {
  group('State and Action', () {
    test('State equality', () {
      final state1 = DartRLState(1);
      final state2 = DartRLState(1);
      final state3 = DartRLState(2);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('Action equality', () {
      final action1 = DartRLAction('up');
      final action2 = DartRLAction('up');
      final action3 = DartRLAction('down');

      expect(action1, equals(action2));
      expect(action1, isNot(equals(action3)));
    });

    test('StateAction equality', () {
      final sa1 = DartRLStateAction(DartRLState(1), DartRLAction('up'));
      final sa2 = DartRLStateAction(DartRLState(1), DartRLAction('up'));
      final sa3 = DartRLStateAction(DartRLState(1), DartRLAction('down'));

      expect(sa1, equals(sa2));
      expect(sa1, isNot(equals(sa3)));
    });
  });

  group('Q-Learning', () {
    test('Q-value initialization', () {
      final agent = QLearningAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRLState(1);
      final action = DartRLAction('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = QLearningAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRLState(1);
      final action = DartRLAction('up');
      final nextState = DartRLState(2);

      agent.update(state, action, 1.0, nextState, [DartRLAction('left')]);

      expect(agent.getQValue(state, action), isNot(equals(0.0)));
    });

    test('Epsilon decay', () {
      final agent = QLearningAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.5,
      );

      agent.decayEpsilon(0.9);
      expect(agent.epsilon, equals(0.45));
    });
  });

  group('SARSA', () {
    test('Q-value initialization', () {
      final agent = SarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRLState(1);
      final action = DartRLAction('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = SarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRLState(1);
      final action = DartRLAction('up');
      final nextState = DartRLState(2);
      final nextAction = DartRLAction('left');

      agent.update(state, action, 1.0, nextState, nextAction);

      expect(agent.getQValue(state, action), isNot(equals(0.0)));
    });
  });

  group('Expected-SARSA', () {
    test('Q-value initialization', () {
      final agent = ExpectedSarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRLState(1);
      final action = DartRLAction('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = ExpectedSarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRLState(1);
      final action = DartRLAction('up');
      final nextState = DartRLState(2);

      agent.update(state, action, 1.0, nextState,
          [DartRLAction('left'), DartRLAction('right')]);

      expect(agent.getQValue(state, action), isNot(equals(0.0)));
    });
  });

  group('GridWorld Example Tests', () {
    test('GridWorld Q-Learning example with detailed output', () {
      print('\n=== GridWorld Q-Learning Test ===\n');

      final environment = GridWorld();
      final agent = QLearningAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      print('Training Q-Learning agent for 500 episodes...');
      agent.train(environment, 500);

      print('\nQ-Table size: ${agent.qTableSize}');
      print('Learning parameters:');
      print('  Learning rate (α): ${agent.learningRate}');
      print('  Discount factor (γ): ${agent.discountFactor}');
      print('  Epsilon (ε): ${agent.epsilon}');

      print('\nSample Q-values:');
      final sampleStates = [
        DartRLState(Point(0, 0)),
        DartRLState(Point(1, 1)),
        DartRLState(Point(2, 2)),
      ];

      for (final state in sampleStates) {
        final qValues = agent.getQValuesForState(state);
        print('  State ${state.value}:');
        for (final entry in qValues.entries) {
          print('    ${entry.key.value}: ${entry.value.toStringAsFixed(2)}');
        }
      }

      print('\nTesting learned policy (greedy):');
      agent.setEpsilon(0.0); // Use greedy policy for testing
      environment.reset();
      int steps = 0;

      while (!environment.isTerminal && steps < 50) {
        final state = environment.currentState;
        final action = agent.selectAction(environment, state);
        final result = environment.step(action);
        print('  Step $steps: Pos=${state.value}, Action=${action.value}, '
            'Reward=${result.reward.toStringAsFixed(1)}, Done=${result.isDone}');
        steps++;
        if (result.isDone) break;
      }

      print('Reached goal in $steps steps!\n');

      // Assertions
      expect(steps, lessThan(50), reason: 'Should reach goal within 50 steps');
      expect(agent.qTableSize, greaterThan(0),
          reason: 'Q-table should have entries');
    });

    test('GridWorld SARSA example with output', () {
      print('\n=== GridWorld SARSA Test ===\n');

      final environment = GridWorld();
      final agent = SarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      print('Training SARSA agent for 500 episodes...');
      agent.train(environment, 500);

      print('\nTesting learned policy:');
      agent.setEpsilon(0.0);
      environment.reset();
      int steps = 0;

      while (!environment.isTerminal && steps < 50) {
        final state = environment.currentState;
        final action = agent.selectAction(environment, state);
        final result = environment.step(action);
        print('  Step $steps: Pos=${state.value}, Action=${action.value}, '
            'Reward=${result.reward.toStringAsFixed(1)}');
        steps++;
        if (result.isDone) break;
      }

      print('SARSA reached goal in $steps steps!\n');

      expect(steps, lessThan(50));
    });

    test('GridWorld Expected-SARSA example with output', () {
      print('\n=== GridWorld Expected-SARSA Test ===\n');

      final environment = GridWorld();
      final agent = ExpectedSarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      print('Training Expected-SARSA agent for 500 episodes...');
      agent.train(environment, 500);

      print('\nTesting learned policy:');
      agent.setEpsilon(0.0);
      environment.reset();
      int steps = 0;

      while (!environment.isTerminal && steps < 50) {
        final state = environment.currentState;
        final action = agent.selectAction(environment, state);
        final result = environment.step(action);
        print('  Step $steps: Pos=${state.value}, Action=${action.value}, '
            'Reward=${result.reward.toStringAsFixed(1)}');
        steps++;
        if (result.isDone) break;
      }

      print('Expected-SARSA reached goal in $steps steps!\n');

      expect(steps, lessThan(50));
    });
  });
}
