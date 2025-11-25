import 'package:flutter/material.dart';

class EmptyListWidget extends StatefulWidget {
  const EmptyListWidget(this.onPressed, this.title, this.message, this.icon, this.buttonText, {super.key});

  final VoidCallback onPressed;
  final String? title;
  final String? message;
  final IconData? icon;
  final String? buttonText;

  @override
  State<EmptyListWidget> createState() => _EmptyListWidgetState();
}

class _EmptyListWidgetState extends State<EmptyListWidget> {
  @override
  Widget build(BuildContext context) {


    var onTertiary2 = Theme.of(context).colorScheme.onTertiary;

    var tertiary2 = Theme.of(context).colorScheme.tertiary;
    var surface2 = Theme.of(context).colorScheme.surface;

    return //List On Empty
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface2,
        border: Border.all(color: tertiary2, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        //
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20.0),
          Icon(
            widget.icon!,
            color: Colors.blueGrey[400],
            size: 36.0,
          ),
          const SizedBox(height: 15.0),

          Text(
            widget.title!,
            style: TextStyle(
              color: onTertiary2,
              fontWeight: FontWeight.w300,
              fontSize: 16.0,
            ),
          ),

          const SizedBox(height: 3.0),

          Text(
            widget.message!,
            style: TextStyle(color: tertiary2),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15.0),
          FilledButton(onPressed: widget.onPressed, child: Text(widget.buttonText!)),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
