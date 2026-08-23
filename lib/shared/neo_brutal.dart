import 'package:flutter/material.dart';

class NeoBrutalCard extends StatelessWidget {
  final Widget child;
  final Color shadowColor;
  final double offset;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const NeoBrutalCard({
    super.key,
    required this.child,
    this.shadowColor = const Color(0xFFFFC107),
    this.offset = 10,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: offset + borderRadius,
          child: Container(
            decoration: BoxDecoration(
              color: shadowColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                bottomLeft: Radius.circular(borderRadius),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: offset),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onTap,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: const Color(0xFF1C1C1E), width: 1.5),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}