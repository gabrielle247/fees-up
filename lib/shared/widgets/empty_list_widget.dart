import 'package:flutter/material.dart';

class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget(this.onPressed, this.title, this.message, this.icon, this.buttonText, {super.key});

  final VoidCallback onPressed;
  final String title;
  final String message;
  final IconData icon;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.tertiary, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blueGrey[400], size: 36.0),
          const SizedBox(height: 15.0),
          Text(
            title,
            style: TextStyle(color: colorScheme.onTertiary, fontSize: 16.0),
          ),
          const SizedBox(height: 3.0),
          Text(
            message,
            style: TextStyle(color: colorScheme.tertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15.0),
          FilledButton(onPressed: onPressed, child: Text(buttonText)),
        ],
      ),
    );
  }
}