import 'package:flutter/material.dart';

class RetroCallingScreen extends StatelessWidget {
  const RetroCallingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // VIBRATING RETRO BACKDROP
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.deepPurple.withOpacity(0.2),
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r"""
    📞 CALL CONNECTING…
    // retro sci-fi modem noises //
                  """,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "Pixel",
                    fontSize: 22,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 40),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "END CALL",
                    style: TextStyle(
                      fontFamily: "Pixel",
                      color: Colors.redAccent,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
