import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final ValueNotifier<int> balance = ValueNotifier<int>(0);
  final ValueNotifier<List<WalletTransaction>> transactions = ValueNotifier<List<WalletTransaction>>([]);

  Future<void> init() async {
    // Load balance from local storage (or Firestore in future)
    final prefs = await SharedPreferences.getInstance();
    balance.value = prefs.getInt('wallet_balance') ?? 0;
    
    // Mock Transaction History
    transactions.value = [
      WalletTransaction(type: 'Bonus', amount: 100, date: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }

  Future<void> recharge(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final newBalance = balance.value + amount;
    
    await prefs.setInt('wallet_balance', newBalance);
    balance.value = newBalance;

    _addTransaction('Recharge', amount);
  }

  Future<bool> deduct(int amount) async {
    if (balance.value < amount) return false;

    final prefs = await SharedPreferences.getInstance();
    final newBalance = balance.value - amount;

    await prefs.setInt('wallet_balance', newBalance);
    balance.value = newBalance;
    
    _addTransaction('Call Payment', -amount);
    return true;
  }

  void _addTransaction(String type, int amount) {
    final newTx = WalletTransaction(type: type, amount: amount, date: DateTime.now());
    transactions.value = [newTx, ...transactions.value];
  }
}

class WalletTransaction {
  final String type;
  final int amount;
  final DateTime date;

  WalletTransaction({required this.type, required this.amount, required this.date});
}
