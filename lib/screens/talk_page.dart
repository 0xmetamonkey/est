import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'call_screen.dart';
import 'wallet_screen.dart';

class TalkPage extends StatefulWidget {
  const TalkPage({super.key});

  @override
  State<TalkPage> createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  // Mock data for links (In real app, this would come from Firestore)
  final List<Map<String, dynamic>> _links = [
    {'icon': Icons.language, 'label': 'My Website', 'url': 'https://example.com'},
    {'icon': Icons.camera_alt, 'label': 'Instagram', 'url': 'https://instagram.com'},
  ];

  void _addNewLink() {
    // Show dialog to add new link
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Link Title (e.g. Portfolio)',
                hintText: 'My Portfolio',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _links.add({
                    'icon': Icons.link, // Default icon
                    'label': titleController.text,
                    'url': urlController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.purple),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Profile Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9C89B8), width: 2),
                  image: DecorationImage(
                    image: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/placeholder_avatar.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 50, color: Color(0xFF9C89B8))
                    : null,
              ),
              const SizedBox(height: 16),
              
              // 2. Name
              Text(
                user?.displayName ?? 'Anonymous Creator',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              
              // 3. Bio / Tagline
              const Text(
                'Ready to talk? Pick an option below.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // 4. Action Buttons (Audio vs Video)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Video Call
                  _ActionCircle(
                    title: 'VIDEO\nCALL',
                    color: const Color(0xFFE0F7FA), // Light Cyan
                    textColor: const Color(0xFF006064),
                    size: 140,
                    icon: Icons.videocam,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CallScreen(
                            isVideoMode: true,
                            channelId: 'demo-channel',
                            // TODO: Fetch from backend
                            token: '007eJxTYOiX64jbKFahn8HnXXPP1XH6ETbWwPyaPN43RmYfYmOM1ygwmBiYm6eZpaUYGBommxilWiYmJiabpximphoYmJumWJp+cyvMbAhkZEgOOsHACIUgPg9DSmpuvm5yRmJeXmoOAwMAUOwfuQ==',
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Audio Call
                  _ActionCircle(
                    title: 'AUDIO\nCALL',
                    color: const Color(0xFFF3E5F5), // Light Purple
                    textColor: const Color(0xFF4A148C),
                    size: 140,
                    icon: Icons.phone, 
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CallScreen(
                            isVideoMode: false,
                            channelId: 'demo-channel',
                            token: '007eJxTYOiX64jbKFahn8HnXXPP1XH6ETbWwPyaPN43RmYfYmOM1ygwmBiYm6eZpaUYGBommxilWiYmJiabpximphoYmJumWJp+cyvMbAhkZEgOOsHACIUgPg9DSmpuvm5yRmJeXmoOAwMAUOwfuQ==',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // 5. Links Section Header + Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All my links',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  IconButton(
                    onPressed: _addNewLink,
                    icon: const Icon(Icons.add_circle, color: Color(0xFF9C89B8)),
                    tooltip: 'Add Link',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 6. Dynamic Links List
              ..._links.map((link) => _LinkItem(
                icon: link['icon'] as IconData, 
                label: link['label'] as String
              )),
              
              if (_links.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No links added yet.', style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final double size;
  final IconData? icon;

  const _ActionCircle({
    required this.title,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.size = 160,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 32, color: textColor),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size * 0.12, // Responsive font size
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LinkItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
