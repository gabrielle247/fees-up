import 'package:flutter/material.dart';

class SidebarItemModel {
  final IconData icon;
  final String label;
  final String route;

  const SidebarItemModel({
    required this.icon,
    required this.label,
    required this.route,
  });
}
