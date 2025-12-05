import 'package:flutter/material.dart';
import 'retro_calling_screen.dart';

class RetroProfileScreen extends StatelessWidget {
  final String name;
  final String bio;
  final double pricePerMinute;

  const RetroProfileScreen({
    super.key,
    required this.name,
    required this.bio,
    required this.pricePerMinute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.pinkAccent, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ASCII ANIME FACE
              Text(
                r"""
      (\_/)
      ( •_•)  < Hi…
     / >💖
                """,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Pixel",
                  color: Colors.pinkAccent,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                name,
                style: TextStyle(
                  fontFamily: "Pixel",
                  fontSize: 22,
                  color: Colors.cyanAccent,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Pixel",
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "₹${pricePerMinute.toStringAsFixed(0)} / minute",
                style: TextStyle(
                  fontFamily: "Pixel",
                  fontSize: 16,
                  color: Colors.yellowAccent,
                ),
              ),

              const SizedBox(height: 30),

              retroButton(
                label: "TALK TO ME",
                color: Colors.greenAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RetroCallingScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              retroButton(
                label: "WRITE TO ME",
                color: Colors.cyanAccent,
                onTap: () {
                  // next screen (chat)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget retroButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(fontFamily: "Pixel", color: color, fontSize: 18),
      ),
    );
  }
}
