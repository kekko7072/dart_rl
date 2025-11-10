import 'dart:math';
import 'package:test/test.dart';
import 'package:dart_rl/dart_rl.dart';

import '../example/grid_world_example.dart';

void main() {
  group('State and Action', () {
    test('State equality', () {
      final state1 = DartRlState(1);
      final state2 = DartRlState(1);
      final state3 = DartRlState(2);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('Action equality', () {
      final action1 = DartRlAction('up');
      final action2 = DartRlAction('up');
      final action3 = DartRlAction('down');

      expect(action1, equals(action2));
      expect(action1, isNot(equals(action3)));
    });

    test('StateAction equality', () {
      final sa1 = DartRlStateAction(DartRlState(1), DartRlAction('up'));
      final sa2 = DartRlStateAction(DartRlState(1), DartRlAction('up'));
      final sa3 = DartRlStateAction(DartRlState(1), DartRlAction('down'));

      expect(sa1, equals(sa2));
      expect(sa1, isNot(equals(sa3)));
    });
  });

  group('Q-Learning', () {
    test('Q-value initialization', () {
      final agent = QLearning(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRlState(1);
      final action = DartRlAction('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = QLearning(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRlState(1);
      final action = DartRlAction('up');
      final nextState = DartRlState(2);

      agent.update(state, action, 1.0, nextState, [DartRlAction('left')]);

      expect(agent.getQValue(state, action), isNot(equals(0.0)));
    });

    test('Epsilon modification', () {
      final agent = QLearning(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.5,
      );

      agent.epsilon = 0.45;
      expect(agent.epsilon, equals(0.45));
    });
  });

  group('SARSA', () {
    test('Q-value initialization', () {
      final agent = SARSA(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRlState(1);
      final action = DartRlAction('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = SARSA(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRlState(1);
      final action = DartRlAction('up');
      final nextState = DartRlState(2);
      final nextAction = DartRlAction('left');

      agent.update(state, action, 1.0, nextState, nextAction);

      expect(agent.getQValue(state, action), isNot(equals(0.0)));
    });
  });

  group('Expected-SARSA', () {
    test('Q-value initialization', () {
      final agent = ExpectedSARSA(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRlState(1);
      final action = DartRlAction('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = ExpectedSARSA(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = DartRlState(1);
      final action = DartRlAction('up');
      final nextState = DartRlState(2);

      agent.update(state, action, 1.0, nextState,
          [DartRlAction('left'), DartRlAction('right')]);

      expect(agent.getQValue(state, action), isNot(equals(0.0)));
    });
  });

  group('GridWorld Example Tests', () {
    test('GridWorld Q-Learning example with detailed output', () {
      print('\n=== GridWorld Q-Learning Test ===\n');

      final environment = GridWorld();
      final agent = QLearning(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      print('Training Q-Learning agent for 500 episodes...');
      agent.train(environment, 500);

      print('\nQ-Table size: ${agent.qTable.length}');
      print('Learning parameters:');
      print('  Learning rate (α): ${agent.learningRate}');
      print('  Discount factor (γ): ${agent.discountFactor}');
      print('  Epsilon (ε): ${agent.epsilon}');

      print('\nSample Q-values:');
      final sampleStates = [
        DartRlState(Point(0, 0)),
        DartRlState(Point(1, 1)),
        DartRlState(Point(2, 2)),
      ];

      for (final state in sampleStates) {
        final qValues = agent.getQValuesForState(state);
        print('  State ${state.value}:');
        for (final entry in qValues.entries) {
          print('    ${entry.key.value}: ${entry.value.toStringAsFixed(2)}');
        }
      }

      print('\nTesting learned policy (greedy):');
      agent.epsilon = 0.0; // Use greedy policy for testing
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
      expect(agent.qTable.length, greaterThan(0),
          reason: 'Q-table should have entries');
    });

    test('GridWorld SARSA example with output', () {
      print('\n=== GridWorld SARSA Test ===\n');

      final environment = GridWorld();
      final agent = SARSA(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      print('Training SARSA agent for 500 episodes...');
      agent.train(environment, 500);

      print('\nTesting learned policy:');
      agent.epsilon = 0.0;
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
      final agent = ExpectedSARSA(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      print('Training Expected-SARSA agent for 500 episodes...');
      agent.train(environment, 500);

      print('\nTesting learned policy:');
      agent.epsilon = 0.0;
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
