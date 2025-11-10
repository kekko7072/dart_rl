import 'dart:convert';
import 'dart:io';
import 'state_action.dart';

/// Serialization utilities for saving and loading Q-tables
class QTableSerializer {
  /// Serialize a Q-table to JSON string
  ///
  /// The Q-table is serialized as a map where keys are string representations
  /// of state-action pairs and values are Q-values.
  static String serialize(Map<DartRLStateAction, double> qTable) {
    final map = <String, double>{};
    for (final entry in qTable.entries) {
      final key = '${entry.key.state.value}|${entry.key.action.value}';
      map[key] = entry.value;
    }
    return jsonEncode(map);
  }

  /// Deserialize a Q-table from JSON string
  ///
  /// Note: This requires knowledge of how states and actions are represented.
  /// For complex state/action types, you may need to provide custom deserializers.
  static Map<DartRLStateAction, double> deserialize(
    String jsonString, {
    DartRLState Function(dynamic)? stateDeserializer,
    DartRLAction Function(dynamic)? actionDeserializer,
  }) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    final qTable = <DartRLStateAction, double>{};

    final stateDeser = stateDeserializer ?? ((v) => DartRLState(v));
    final actionDeser = actionDeserializer ?? ((v) => DartRLAction(v));

    for (final entry in map.entries) {
      final parts = entry.key.split('|');
      if (parts.length == 2) {
        final state = stateDeser(parts[0]);
        final action = actionDeser(parts[1]);
        final qValue = (entry.value as num).toDouble();
        qTable[DartRLStateAction(state, action)] = qValue;
      }
    }

    return qTable;
  }

  /// Save Q-table to a file
  static Future<void> saveToFile(
    String filePath,
    Map<DartRLStateAction, double> qTable,
  ) async {
    final jsonString = serialize(qTable);
    await File(filePath).writeAsString(jsonString);
  }

  /// Load Q-table from a file
  static Future<Map<DartRLStateAction, double>> loadFromFile(
    String filePath, {
    DartRLState Function(dynamic)? stateDeserializer,
    DartRLAction Function(dynamic)? actionDeserializer,
  }) async {
    final jsonString = await File(filePath).readAsString();
    return deserialize(
      jsonString,
      stateDeserializer: stateDeserializer,
      actionDeserializer: actionDeserializer,
    );
  }
}
