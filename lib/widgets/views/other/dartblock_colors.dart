import 'package:flutter/material.dart';
import 'package:dartblock/models/dartblock_value.dart';

final class DartBlockColors {
  DartBlockColors._();
  // static const number = Color.fromARGB(255, 4, 86, 118);
  // static const boolean = Color.fromARGB(255, 8, 94, 80);
  // static const variable = Color.fromARGB(255, 95, 69, 93);
  // static const function = Color.fromARGB(255, 69, 95, 71);
  // static const string = Color.fromARGB(255, 143, 0, 45);
  static const number = Color.fromARGB(255, 87, 85, 170);
  static const boolean = Color.fromARGB(255, 170, 85, 126);
  static const variable = Color.fromARGB(255, 134, 136, 68);
  static const function = Color.fromARGB(255, 69, 95, 71);
  static const string = Color.fromARGB(255, 85, 170, 129);
  static Color getNeoTechDataTypeColor(DartBlockDataType dataType) {
    switch (dataType) {
      case DartBlockDataType.integerType:
      case DartBlockDataType.doubleType:
        return number;
      case DartBlockDataType.booleanType:
        return boolean;
      case DartBlockDataType.stringType:
        return string;
    }
  }
}
