import 'package:flutter/material.dart';

class SpinnerLayout extends StatefulWidget {
  const SpinnerLayout(this.title, this.items, this.defaultOption, {this.onChanged, super.key});

  final String title;
  final List<String> items;
  final String defaultOption;
  final ValueChanged<String>? onChanged;


  @override
  State<SpinnerLayout> createState() => _SpinnerLayoutState();
}

class _SpinnerLayoutState extends State<SpinnerLayout> {
  String? selectedFrequency;

  bool? isPaid;

  @override
  void initState() {
    super.initState();
    selectedFrequency = widget.defaultOption;
  }
  //

  @override
  Widget build(BuildContext context) {
    var subTitle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: subTitle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface, // Dark card background
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFrequency,
              isExpanded: true,
              iconEnabledColor: Colors.grey.shade400,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFrequency = value;
                  });
                  widget.onChanged?.call(value);
                }
              },
              items: widget.items
                  .map(
                    (freq) => DropdownMenuItem(value: freq, child: Text(freq)),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
