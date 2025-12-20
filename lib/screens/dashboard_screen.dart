import 'package:est/widgets/retro_background.dart';
import 'package:est/widgets/retro_button.dart';
import 'package:est/screens/audio_test_screen.dart';
import 'package:est/screens/call_screen.dart';
import 'package:est/screens/audio_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return RetroBackground(
        child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        colors: [Colors.cyan, Colors.purpleAccent],
                      ).createShader(rect);
                    },
                    child: const Text(
                      "DASHBOARD",
                      style: TextStyle(
                        fontFamily: "Pixel",
                        color: Colors.white,
                        fontSize: 32,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RetroButton(
                    label: "LOGOUT",
                    color: Colors.redAccent,
                    fontSize: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.purple, thickness: 2, height: 40),

              // PROFILE SECTION
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.pinkAccent, width: 3),
                        boxShadow: [
                           BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.5),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.black,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Text("👤", style: TextStyle(fontSize: 30))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? "Unknown User",
                            style: const TextStyle(
                              fontFamily: "Pixel",
                              fontSize: 24,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          Text(
                            user?.email ?? "",
                            style: TextStyle(
                              fontFamily: "Pixel",
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BUTTONS
              Column(
                children: [
                   RetroButton(
                      label: "BECOME A CREATOR",
                      color: Colors.pinkAccent,
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Become a Creator - Coming Soon!")),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    RetroButton(
                      label: "BROWSE CREATORS",
                      color: Colors.cyanAccent,
                      onTap: () {
                        // TODO: Navigate to browse
                      },
                    ),
                    const SizedBox(height: 16),
                    RetroButton(
                      label: "AUDIO LAB (TEST)",
                      color: Colors.amberAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AudioTestScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    RetroButton(
                      label: "VIDEO UPLINK",
                      color: Colors.deepPurpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CallScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    RetroButton(
                      label: "AUDIO LINK",
                      color: Colors.greenAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AudioCallScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    RetroButton(
                      label: "WALLET",
                      color: Colors.amberAccent,
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Wallet - Coming Soon!")),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
