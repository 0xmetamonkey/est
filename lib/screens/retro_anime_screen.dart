import 'package:est/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class RetroAnimeScreen extends StatelessWidget {
  const RetroAnimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // VHS NOISE OVERLAY (Anime effect)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.purple.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // MAIN CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ASCII ANIME HEAD (retro vibe)
                Text(
                  r"""
       (\_/)
      ( •_•)
     / >❤️   WELCOME TO ED
                  """,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Pixel",
                    color: Colors.pinkAccent,
                    fontSize: 22,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 30),

                // GLITCH TITLE
                ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      colors: [Colors.cyan, Colors.purpleAccent],
                    ).createShader(rect);
                  },
                  child: Text(
                    "RETRO ANIME INTERFACE",
                    style: TextStyle(
                      fontFamily: "Pixel",
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // BUTTON CHAOS
                Column(
                  children: [
                    retroButton(
                      label: "ENTER",
                      color: Colors.cyanAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WelcomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    retroButton(
                      label: "PROFILE",
                      color: Colors.amberAccent,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    retroButton(
                      label: "I'M A CREATOR",
                      color: Colors.pinkAccent,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    retroButton(
                      label: "I'M AN ADMIRER",
                      color: Colors.greenAccent,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // CRT SCREEN GLOW
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.04),
                      Colors.transparent,
                    ],
                    radius: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(fontFamily: "Pixel", color: color, fontSize: 18),
      ),
    );
  }
}
