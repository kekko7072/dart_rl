import 'package:test/test.dart';
import 'package:dart_rl/dart_rl.dart';

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
}
