import 'package:flutter/material.dart';
import 'audio_call_screen.dart';

class RetroProfileScreen extends StatefulWidget {
  final String name;
  final String bio;
  final double pricePerMinute;
  final String upiId;

  const RetroProfileScreen({
    super.key,
    required this.name,
    required this.bio,
    required this.pricePerMinute,
    required this.upiId,
  });

  @override
  State<RetroProfileScreen> createState() => _RetroProfileScreenState();
}

class _RetroProfileScreenState extends State<RetroProfileScreen> {
  bool _isProcessing = false;

  Future<void> _initiatePayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment for MVP - in production, integrate actual UPI
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);
      
      // For MVP: Show dialog asking user to confirm payment
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.greenAccent, width: 2),
          title: const Text(
            'PAYMENT',
            style: TextStyle(
              fontFamily: 'Pixel',
              color: Colors.greenAccent,
            ),
          ),
          content: Text(
            'Pay ₹${widget.pricePerMinute.toStringAsFixed(0)} to ${widget.name}\n\nUPI ID: ${widget.upiId}\n\nHave you completed the payment?',
            style: const TextStyle(
              fontFamily: 'Pixel',
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  fontFamily: 'Pixel',
                  color: Colors.redAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'YES, PAID',
                style: TextStyle(
                  fontFamily: 'Pixel',
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        // Payment confirmed, navigate to call screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AudioCallScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.pinkAccent, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ASCII ANIME FACE
              Text(
                r"""
      (\\_/)
      ( •_•)  < Hi…
     / >💖
                """,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Pixel",
                  color: Colors.pinkAccent,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.name,
                style: const TextStyle(
                  fontFamily: "Pixel",
                  fontSize: 22,
                  color: Colors.cyanAccent,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Pixel",
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "₹${widget.pricePerMinute.toStringAsFixed(0)} / minute",
                style: const TextStyle(
                  fontFamily: "Pixel",
                  fontSize: 16,
                  color: Colors.yellowAccent,
                ),
              ),

              const SizedBox(height: 30),

              _isProcessing
                  ? const CircularProgressIndicator(color: Colors.greenAccent)
                  : retroButton(
                      label: "CALL ME (₹${widget.pricePerMinute.toStringAsFixed(0)}/min)",
                      color: Colors.greenAccent,
                      onTap: _initiatePayment,
                    ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(fontFamily: "Pixel", color: color, fontSize: 18),
      ),
    );
  }
}

