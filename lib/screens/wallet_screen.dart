import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();

  @override
  void initState() {
    super.initState();
    _walletService.init();
  }

  void _showRechargeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Top Up Wallet", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RechargeOption(tokens: 100, price: "\$1.00", onTap: () => _processRecharge(100)),
                _RechargeOption(tokens: 500, price: "\$4.50", isPopular: true, onTap: () => _processRecharge(500)),
                _RechargeOption(tokens: 1000, price: "\$8.00", onTap: () => _processRecharge(1000)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processRecharge(int amount) async {
    Navigator.pop(context); // Close sheet
    // Simulate Network Delay
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Processing Payment...")));
    await Future.delayed(const Duration(seconds: 1));
    
    await _walletService.recharge(amount);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Success! Added $amount Tokens."),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Wallet", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<int>(
                    valueListenable: _walletService.balance,
                    builder: (context, val, _) {
                      return Text(
                        "$val",
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const Text("TOKENS", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showRechargeSheet,
                    icon: const Icon(Icons.add),
                    label: const Text("RECHARGE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            
            // History List
            Expanded(
              child: ValueListenableBuilder<List<WalletTransaction>>(
                valueListenable: _walletService.transactions,
                builder: (context, list, _) {
                  if (list.isEmpty) {
                    return const Center(child: Text("No transactions yet.", style: TextStyle(color: Colors.grey)));
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final tx = list[index];
                      final isPositive = tx.amount > 0;
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPositive ? Colors.green[50] : Colors.red[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isPositive ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ),
                        title: Text(tx.type),
                        subtitle: Text("${tx.date.day}/${tx.date.month} ${tx.date.hour}:${tx.date.minute}"),
                        trailing: Text(
                          "${isPositive ? '+' : ''}${tx.amount}",
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RechargeOption extends StatelessWidget {
  final int tokens;
  final String price;
  final VoidCallback onTap;
  final bool isPopular;

  const _RechargeOption({required this.tokens, required this.price, required this.onTap, this.isPopular = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPopular ? const Color(0xFFE1BEE7) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: isPopular ? Border.all(color: Colors.purple, width: 2) : Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Text("$tokens", style: TextStyle(color: isPopular ? Colors.purple[900] : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Tokens", style: TextStyle(color: isPopular ? Colors.purple[700] : Colors.white54, fontSize: 10)),
            const SizedBox(height: 8),
            Text(price, style: TextStyle(color: isPopular ? Colors.black : Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
