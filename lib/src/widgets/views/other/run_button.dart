// import 'package:flutter/material.dart';

// enum _ButtonState { idle, running, success, failure }

// class RunButton extends StatefulWidget {
//   final Function()? onPressed;
//   const RunButton({super.key, this.onPressed});

//   @override
//   State<RunButton> createState() => _RunButtonState();
// }

// class _RunButtonState extends State<RunButton> {
//   _ButtonState _state = _ButtonState.idle;
//   @override
//   Widget build(BuildContext context) {
//     return FilledButton.icon(
//       onPressed: widget.onPressed,
//       label: const Text('Run'),
//       icon: _buildIcon(),
//     );
//   }

//   Widget _buildIcon() {
//     switch (_state) {
//       case _ButtonState.idle:
//         return const Icon(Icons.play_arrow);
//       case _ButtonState.running:
//         return const SizedBox(
//           width: 16,
//           height: 16,
//           child: CircularProgressIndicator(strokeWidth: 2),
//         );
//       case _ButtonState.success:
//         return const Icon(Icons.check);
//       case _ButtonState.failure:
//         return const Icon(Icons.error);
//     }
//   }
// }
