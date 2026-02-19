// import 'package:dartblock_code/core/dartblock_executor.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:dartblock_code/core/dartblock_program.dart';
// import 'package:dartblock_code/models/statement.dart';
// import 'package:dartblock_code/models/dartblock_value.dart';

// void main() {
//   group('DartBlockProgram Tests', () {
//     test('should create empty DartBlockProgram', () {
//       final program = DartBlockProgram.init([], []);
//       expect(program.isEmpty(), isTrue);
//       expect(program.mainFunction.statements.isEmpty, isTrue);
//       expect(program.customFunctions.isEmpty, isTrue);
//     });

//     test('should create Hello World DartBlockProgram', () async {
//       final statements = [
//         PrintStatement.init(
//           DartBlockConcatenationValue.init([
//             DartBlockStringValue.init("Hello World"),
//           ]),
//         ),
//       ];
//       final program = DartBlockProgram.init(statements, []);

//       expect(program.isEmpty(), isFalse);
//       expect(program.mainFunction.statements.length, equals(1));
//       expect(program.customFunctions.isEmpty, isTrue);
//       final executor = DartBlockExecutor(program);
//       await expectLater(executor.execute(), completes);
//     });

//     test('should create deep copy of example DartBlockProgram correctly', () {
//       final originalProgram = DartBlockProgram.example();
//       final copiedProgram = originalProgram.copy();

//       expect(copiedProgram, isNotNull);
//       expect(copiedProgram.toScript(), equals(originalProgram.toScript()));
//       expect(copiedProgram.mainLanguage, equals(originalProgram.mainLanguage));
//       expect(copiedProgram.version, equals(originalProgram.version));

//       final originalProgramMainFunctionLength =
//           originalProgram.mainFunction.statements.length;
//       final copiedProgramMainFunctionLength =
//           copiedProgram.mainFunction.statements.length;

//       copiedProgram.mainFunction.statements.removeLast();
//       expect(
//         originalProgram.mainFunction.statements.length,
//         equals(originalProgramMainFunctionLength),
//       );
//       expect(
//         copiedProgramMainFunctionLength,
//         isNot(
//           equals(
//             copiedProgram.mainFunction.statements.length,
//             originalProgramMainFunctionLength,
//           ),
//         ),
//       );
//       expect(
//         copiedProgram.mainFunction.statements.length,
//         equals(copiedProgramMainFunctionLength - 1),
//       );
//     });

//     test(
//       'should serialize and deserialize the example DartBlockProgram to/from JSON correctly',
//       () {
//         final originalProgram = DartBlockProgram.example();
//         final jsonEncoded = originalProgram.toJson();
//         final decodedProgram = DartBlockProgram.fromJson(jsonEncoded);

//         expect(decodedProgram, isNotNull);
//         expect(decodedProgram.isEmpty(), isFalse);
//         expect(decodedProgram.toScript(), equals(originalProgram.toScript()));
//         expect(
//           decodedProgram.mainLanguage,
//           equals(originalProgram.mainLanguage),
//         );
//         expect(decodedProgram.version, equals(originalProgram.version));
//       },
//     );
//   });
// }
