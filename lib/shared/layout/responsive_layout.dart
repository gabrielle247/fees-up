import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget pcScaffold;

  // Standard breakpoint: Tablets usually go up to 768px or 1024px.
  // We will treat anything above 850px as PC to accommodate larger tablets/landscape.
  static const double pcBreakpoint = 850.0;

  const ResponsiveLayout({
    super.key,
    required this.mobileScaffold,
    required this.pcScaffold,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < pcBreakpoint) {
          return mobileScaffold;
        } else {
          return pcScaffold;
        }
      },
    );
  }
}