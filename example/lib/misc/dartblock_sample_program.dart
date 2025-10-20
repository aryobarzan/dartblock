import 'package:json_annotation/json_annotation.dart';
import 'package:dartblock_code/dartblock.dart';
part 'dartblock_sample_program.g.dart';

@JsonSerializable()
class DartBlockSampleProgram {
  final String title;
  final String description;
  final int index;
  final DartBlockProgram program;
  DartBlockSampleProgram(
    this.title,
    this.description,
    this.index,
    this.program,
  );

  factory DartBlockSampleProgram.fromJson(Map<String, dynamic> json) =>
      _$DartBlockSampleProgramFromJson(json);

  Map<String, dynamic> toJson() => _$DartBlockSampleProgramToJson(this);
}
