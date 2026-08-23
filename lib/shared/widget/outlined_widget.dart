import 'package:flutter/material.dart';

class OutlinedCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const OutlinedCard({
    super.key,
    required this.child,
    this.borderColor = const Color(0xFF1C1C1E),
    this.borderWidth = 1.5,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}