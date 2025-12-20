import 'package:est/screens/retro_profile_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ED Marketplace',
      home: const RetroProfileScreen(
        name: "Luna",
        bio: "Available for voice calls 💖",
        pricePerMinute: 50.0,
        upiId: "yourupiid@paytm", // REPLACE WITH YOUR UPI ID
      ),
    );
  }
}
