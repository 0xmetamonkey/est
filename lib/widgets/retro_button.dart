import 'package:flutter/material.dart';

class RetroButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const RetroButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.fontSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: Colors.black.withOpacity(0.5), 
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        padding: padding,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Pixel",
            color: color,
            fontSize: fontSize,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: color,
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
