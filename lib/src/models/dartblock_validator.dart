/// Helper class.
class DartBlockValidator {
  static String? validateVariableName(String name) {
    // 1
    if (name.isEmpty) {
      return 'Variable names must not be empty.';
    }
    // 2
    var numberExp = RegExp(r'[0-9]');
    if (name.startsWith(numberExp)) {
      return 'Variable names must not start with a digit.';
    }
    // 3
    final allowedCharacters = RegExp(r'^[a-zA-Z0-9\_\$]+$');
    if (!name.contains(allowedCharacters)) {
      return "Variable names can only contain letters, digits, the dollar sign '\$' or underscore '_'.";
    }

    var allowedExp = RegExp(r'[a-zA-z\_\$]');
    if (name.startsWith(allowedExp)) {
      return null;
    }

    return 'Variable names must start with a letter.';
  }

  static String? validateFunctionName(String name) {
    // 1
    if (name.isEmpty) {
      return 'Variable names must not be empty.';
    }
    // 2
    var numberExp = RegExp(r'[0-9]');
    if (name.startsWith(numberExp)) {
      return 'Variable names must not start with a digit.';
    }
    // 3
    final allowedCharacters = RegExp(r'^[a-zA-Z0-9\_\$]+$');
    if (!name.contains(allowedCharacters)) {
      return "Variable names can only contain letters, digits, the dollar sign '\$' or underscore '_'.";
    }
    // 4
    if (name == "main") {
      return "The keyword 'main' is reserved.";
    }

    var allowedExp = RegExp(r'[a-zA-z\_\$]');
    if (name.startsWith(allowedExp)) {
      return null;
    }

    return 'Variable names must start with a letter.';
  }
}
