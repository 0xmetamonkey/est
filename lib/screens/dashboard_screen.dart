import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE SECTION
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? "Unknown User",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BUTTONS
            ElevatedButton(
              onPressed: () {
                // TODO: Become Creator
              },
              child: const Text("Become a Creator"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // TODO: Browse Creators
              },
              child: const Text("Browse Creators"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // TODO: Messages
              },
              child: const Text("Messages"),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // TODO: Wallet
              },
              child: const Text("Wallet"),
            ),
          ],
        ),
      ),
    );
  }
}
