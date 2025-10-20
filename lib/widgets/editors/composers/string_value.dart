import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartblock_code/models/dartblock_value.dart';

class StringValueComposer extends StatefulWidget {
  final DartBlockStringValue? value;
  final Function(DartBlockStringValue?) onChange;
  final Function(String value)? onSubmitted;
  const StringValueComposer({
    super.key,
    this.value,
    required this.onChange,
    this.onSubmitted,
  });

  @override
  State<StringValueComposer> createState() => _StringValueComposerState();
}

class _StringValueComposerState extends State<StringValueComposer> {
  late DartBlockStringValue value;
  late final TextEditingController tec;
  final GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      value = widget.value!.copy();
    } else {
      value = DartBlockStringValue.init("");
    }
    tec = TextEditingController(text: value.value);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: TextFormField(
        autofocus: true,
        controller: tec,
        maxLines: null,
        onFieldSubmitted: (value) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!(value);
          }
        },
        textInputAction: TextInputAction.done,
        inputFormatters: [LengthLimitingTextInputFormatter(2048)],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Text",
        ),
        onChanged: (newText) {
          setState(() {
            value.value = newText;
          });
          widget.onChange(newText.isEmpty ? null : value);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "The text cannot be empty.";
          }

          return null;
        },
      ),
    );
  }
}
