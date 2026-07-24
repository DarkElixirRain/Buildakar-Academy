import 'package:flutter/material.dart';

class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const AppSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Continue',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (onPressed != null) onPressed!();
          },
          child: Text(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

void showAppSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'Continue',
  VoidCallback? onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AppSuccessDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    ),
  );
}
