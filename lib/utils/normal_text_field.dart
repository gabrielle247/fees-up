import 'package:flutter/material.dart';

class NormalTextField extends StatefulWidget {
  const NormalTextField({super.key});

  @override
  State<NormalTextField> createState() => _NormalTextFieldState();
}

class _NormalTextFieldState extends State<NormalTextField> {
  @override
  Widget build(BuildContext context) {
    var title = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500);
    var subTitle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500);

    return Column(
      children: [
        Text("Academic Information", style: title),
        const SizedBox(height: 16.0),
        Text("Subjects", style: subTitle),
        const TextField(
          decoration: InputDecoration.collapsed(hintText: 'Enter text here'),
        ),
      ],
      //
    );
  }
}
