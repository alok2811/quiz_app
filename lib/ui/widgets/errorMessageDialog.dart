import 'package:flutter/material.dart';

class ErrorMessageDialog extends StatelessWidget {
  final String? errorMessage;
  const ErrorMessageDialog({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        errorMessage!,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}
