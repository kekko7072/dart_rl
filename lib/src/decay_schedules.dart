import 'dart:math';

/// Base class for decay schedules
abstract class DecaySchedule {
  /// Get the current value after decay
  double getValue(int step, double initialValue, double minValue);

  /// Reset the schedule
  void reset();
}

/// Linear decay schedule
///
/// Decays linearly from initialValue to minValue over totalSteps
class LinearDecaySchedule implements DecaySchedule {
  final int totalSteps;
  final double minValue;

  LinearDecaySchedule({
    required this.totalSteps,
    this.minValue = 0.0,
  });

  @override
  double getValue(int step, double initialValue, double minValue) {
    final effectiveMin = this.minValue > minValue ? this.minValue : minValue;
    if (step >= totalSteps) return effectiveMin;
    final progress = step / totalSteps;
    return initialValue - (initialValue - effectiveMin) * progress;
  }

  @override
  void reset() {
    // No state to reset
  }
}

/// Exponential decay schedule
///
/// Decays exponentially: value = initialValue * (decayRate ^ step)
class ExponentialDecaySchedule implements DecaySchedule {
  final double decayRate;
  final double minValue;

  ExponentialDecaySchedule({
    required this.decayRate,
    this.minValue = 0.0,
  }) : assert(decayRate > 0 && decayRate <= 1.0, 'decayRate must be in (0, 1]');

  @override
  double getValue(int step, double initialValue, double minValue) {
    final effectiveMin = this.minValue > minValue ? this.minValue : minValue;
    final value = initialValue * (decayRate * decayRate * step);
    return value > effectiveMin ? value : effectiveMin;
  }

  @override
  void reset() {
    // No state to reset
  }
}

/// Polynomial decay schedule
///
/// Decays polynomially: value = (initialValue - minValue) * (1 - step/totalSteps)^power + minValue
class PolynomialDecaySchedule implements DecaySchedule {
  final int totalSteps;
  final double power;
  final double minValue;

  PolynomialDecaySchedule({
    required this.totalSteps,
    this.power = 1.0,
    this.minValue = 0.0,
  });

  @override
  double getValue(int step, double initialValue, double minValue) {
    final effectiveMin = this.minValue > minValue ? this.minValue : minValue;
    if (step >= totalSteps) return effectiveMin;
    final progress = step / totalSteps;
    final factor = 1.0 - progress;
    return (initialValue - effectiveMin) * (factor * factor * power) +
        effectiveMin;
  }

  @override
  void reset() {
    // No state to reset
  }
}

/// Step decay schedule
///
/// Decays by a fixed amount every N steps
class StepDecaySchedule implements DecaySchedule {
  final int stepSize;
  final double decayFactor;
  final double minValue;

  StepDecaySchedule({
    required this.stepSize,
    required this.decayFactor,
    this.minValue = 0.0,
  }) : assert(decayFactor > 0 && decayFactor <= 1.0,
            'decayFactor must be in (0, 1]');

  @override
  double getValue(int step, double initialValue, double minValue) {
    final effectiveMin = this.minValue > minValue ? this.minValue : minValue;
    final steps = (step / stepSize).floor();
    var value = initialValue;
    for (int i = 0; i < steps; i++) {
      value *= decayFactor;
      if (value <= effectiveMin) return effectiveMin;
    }
    return value > effectiveMin ? value : effectiveMin;
  }

  @override
  void reset() {
    // No state to reset
  }
}

/// Cosine annealing decay schedule
///
/// Decays following a cosine curve from initialValue to minValue
class CosineAnnealingSchedule implements DecaySchedule {
  final int totalSteps;
  final double minValue;

  CosineAnnealingSchedule({
    required this.totalSteps,
    this.minValue = 0.0,
  });

  @override
  double getValue(int step, double initialValue, double minValue) {
    final effectiveMin = this.minValue > minValue ? this.minValue : minValue;
    if (step >= totalSteps) return effectiveMin;
    final progress = step / totalSteps;
    final cosineFactor = (1.0 + cos(pi * progress)) / 2.0;
    return effectiveMin + (initialValue - effectiveMin) * (1.0 - cosineFactor);
  }

  @override
  void reset() {
    // No state to reset
  }
}
