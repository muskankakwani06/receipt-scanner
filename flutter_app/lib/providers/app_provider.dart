import 'package:flutter/material.dart';
import '../models/receipt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import 'dart:typed_data';

class AppProvider extends ChangeNotifier {
  final SettingsService settings;
  final DatabaseService db;
  final GeminiService gemini;
  final StorageService storage;

  List<Receipt> _receipts = [];
  bool _isLoading = false;
  int _currentTab = 0;

  AppProvider({
    required this.settings,
    required this.db,
    required this.gemini,
    required this.storage,
  }) {
    loadReceipts();
  }

  List<Receipt> get receipts => _receipts;
  bool get isLoading => _isLoading;
  int get currentTab => _currentTab;

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  String get userName {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return settings.userName; // Fallback to settings or Alex Johnson
  }

  Future<void> loadReceipts() async {
    _isLoading = true;
    notifyListeners();
    _receipts = await db.getReceipts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveReceipt(Receipt receipt) async {
    await db.insertReceipt(receipt);
    await loadReceipts();
  }

  Future<String?> uploadReceiptImage(Uint8List bytes, String merchant) async {
    final fileName = '${merchant.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await storage.uploadReceiptImage(bytes, fileName);
  }

  Future<void> clearHistory() async {
    await db.clearHistory();
    await loadReceipts();
  }

  double get monthlySpent {
    final now = DateTime.now();
    return _receipts
        .where((r) => r.savedAt.month == now.month && r.savedAt.year == now.year)
        .fold(0, (sum, r) => sum + r.total);
  }

  double get remainingBudget => (settings.budget - monthlySpent).clamp(0.0, double.infinity);

  double get budgetProgress => (monthlySpent / settings.budget).clamp(0.0, 1.0);

  Map<String, double> get categoryTotals {
    final now = DateTime.now();
    final Map<String, double> totals = {};
    for (var r in _receipts) {
      if (r.savedAt.month == now.month && r.savedAt.year == now.year) {
        for (var item in r.items) {
          totals[item.category] = (totals[item.category] ?? 0) + item.price;
        }
      }
    }
    return totals;
  }

  // Settings proxies
  void updateBudget(double value) {
    settings.budget = value;
    notifyListeners();
  }

  void updateApiKey(String value) {
    settings.apiKey = value;
    notifyListeners();
  }

  void updateCurrency(String value) {
    settings.currency = value;
    notifyListeners();
  }
}
