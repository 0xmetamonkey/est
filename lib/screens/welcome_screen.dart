import 'package:est/screens/dashboard_screen.dart';
import 'package:est/widgets/retro_background.dart';
import 'package:est/widgets/retro_button.dart'; // Import RetroButton
import 'package:flutter/material.dart';
import '../services/google_signin_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RetroBackground(
        child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // GLITCH TITLE
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                colors: [Colors.cyan, Colors.purpleAccent],
              ).createShader(rect);
            },
            child: const Text(
              "ACCESS PORTAL",
              style: TextStyle(
                fontFamily: "Pixel",
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: RetroButton(
                label: "CONTINUE WITH GOOGLE",
                color: Colors.white,
                onTap: () async {
                  final userCred = await GoogleSignInService.signInWithGoogle();
                  if (userCred != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    );
                  }
                }),
          ),
        ],
      ),
    ));
  }
}
