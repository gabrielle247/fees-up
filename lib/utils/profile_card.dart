import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.iconSize, {super.key});
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    var onTertiary2 = Theme.of(context).colorScheme.onTertiary;

    var tertiary2 = Theme.of(context).colorScheme.tertiary;

    return Container(
      decoration: BoxDecoration(
        color: tertiary2,
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 0),
      padding: const EdgeInsets.all(5.0),
      child: Icon(Icons.person_outline_rounded, color: onTertiary2, size: iconSize,),
    );
  }
}
//