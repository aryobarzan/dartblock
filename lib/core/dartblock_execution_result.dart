import 'package:dartblock_code/models/environment.dart';
import 'package:dartblock_code/models/exception.dart';
import 'package:dartblock_code/models/statement.dart';
import 'package:json_annotation/json_annotation.dart';
part 'dartblock_execution_result.g.dart';

@JsonSerializable(explicitToJson: true)
class DartBlockExecutionResult {
  final List<String> consoleOutput;
  final Map<String, dynamic> environment;
  final int currentStatementBlockKey;
  final Map<String, dynamic>? currentStatement;
  final List<int> blockHistory;
  Map<String, dynamic>? exception;

  DartBlockExecutionResult({
    required this.consoleOutput,
    required this.environment,
    required this.currentStatementBlockKey,
    required this.currentStatement,
    required this.blockHistory,
    required this.exception,
  });

  factory DartBlockExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$DartBlockExecutionResultFromJson(json);

  Map<String, dynamic> toJson() => _$DartBlockExecutionResultToJson(this);

  DartBlockEnvironment? getEnvironment() {
    return DartBlockEnvironment.fromJson(environment);
  }

  Statement? getCurrentStatement() {
    if (currentStatement == null) {
      return null;
    }
    return Statement.fromJson(currentStatement!);
  }

  DartBlockException? getException() {
    if (exception == null) {
      return null;
    }
    return DartBlockException.fromJson(exception!);
  }
}
