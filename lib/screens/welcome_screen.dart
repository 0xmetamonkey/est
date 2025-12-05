import 'package:flutter/material.dart';
import '../services/google_signin_service.dart';
import 'package:est/screens/dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Continue with Google"),
          onPressed: () async {
            final userCred = await GoogleSignInService.signInWithGoogle();
            if (userCred != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DashboardScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
