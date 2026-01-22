import 'package:flutter/material.dart';

class GivePage extends StatelessWidget {
  const GivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give'),
      ),
      body: const Center(
        child: Text(
          'Give Page - Coming Soon',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
