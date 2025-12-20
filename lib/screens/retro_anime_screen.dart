import 'package:est/screens/welcome_screen.dart';
import 'package:est/widgets/retro_background.dart';
import 'package:est/widgets/retro_button.dart';
import 'package:flutter/material.dart';

class RetroAnimeScreen extends StatelessWidget {
  const RetroAnimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RetroBackground(
      child: Center(
        child: SingleChildScrollView(
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
                  shadows: [
                    Shadow(
                      color: Colors.pinkAccent.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                  ],
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
                child: const Text(
                  "RETRO ANIME INTERFACE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Pixel",
                    color: Colors.white,
                    fontSize: 24, // Slightly larger
                    letterSpacing: 4, // More spacing
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // BUTTON CHAOS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RetroButton(
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
                    const SizedBox(height: 20),
                    RetroButton(
                      label: "PROFILE",
                      color: Colors.amberAccent,
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile feature coming soon!")),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    RetroButton(
                      label: "I'M A CREATOR",
                      color: Colors.pinkAccent,
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Creator mode coming soon!")),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    RetroButton(
                      label: "I'M AN ADMIRER",
                      color: Colors.greenAccent,
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Admirer mode coming soon!")),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
