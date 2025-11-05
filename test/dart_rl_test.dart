import 'package:test/test.dart';
import 'package:dart_rl/dart_rl.dart';

void main() {
  group('State and Action', () {
    test('State equality', () {
      final state1 = State(1);
      final state2 = State(1);
      final state3 = State(2);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('Action equality', () {
      final action1 = Action('up');
      final action2 = Action('up');
      final action3 = Action('down');

      expect(action1, equals(action2));
      expect(action1, isNot(equals(action3)));
    });

    test('StateAction equality', () {
      final sa1 = StateAction(State(1), Action('up'));
      final sa2 = StateAction(State(1), Action('up'));
      final sa3 = StateAction(State(1), Action('down'));

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

      final state = State(1);
      final action = Action('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = QLearningAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = State(1);
      final action = Action('up');
      final nextState = State(2);

      agent.update(state, action, 1.0, nextState, [Action('left')]);

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

      final state = State(1);
      final action = Action('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = SarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = State(1);
      final action = Action('up');
      final nextState = State(2);
      final nextAction = Action('left');

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

      final state = State(1);
      final action = Action('up');

      expect(agent.getQValue(state, action), equals(0.0));
    });

    test('Q-value update', () {
      final agent = ExpectedSarsaAgent(
        learningRate: 0.1,
        discountFactor: 0.9,
        epsilon: 0.1,
      );

      final state = State(1);
      final action = Action('up');
      final nextState = State(2);

      agent.update(state, action, 1.0, nextState, [Action('left'), Action('right')]);

      expect(agent.getQValue(state, action), isNot(equals(0.0)));
    });
  });
}
