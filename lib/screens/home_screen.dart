import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Logged in as: ${user?.email}",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
return Scaffold(
  backgroundColor = Colors.black,
  body = Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Hello Aman",
          style: TextStyle(color: Colors.pinkAccent, fontSize: 32),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            print("Button tapped!");
          },
          child: Text("Tap Me"),
        ),
      ],
    ),
  ),
);
