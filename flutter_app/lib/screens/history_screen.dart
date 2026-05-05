import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/receipt.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final receipts = provider.receipts;
    final cur = provider.settings.currency;

    // Group by date
    final Map<String, List<Receipt>> groups = {};
    for (var r in receipts) {
      final dateKey = DateFormat('d MMMM yyyy').format(r.savedAt);
      groups.putIfAbsent(dateKey, () => []).add(r);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
            SizedBox(width: 12),
            Text('Receipt Scanner +', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppTheme.danger),
            onPressed: () => _confirmClear(context, provider),
          ),
        ],
      ),
      body: receipts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final date = groups.keys.elementAt(index);
                final groupReceipts = groups[date]!;
                return _buildDateGroup(date, groupReceipts, cur);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.clipboardList, size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          const Text('No history yet', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Scanned receipts will appear here', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Receipt> groupReceipts, String cur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            date.toUpperCase(),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        ...groupReceipts.map((r) => _buildReceiptTile(r, cur)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReceiptTile(Receipt r, String cur) {
    final topCat = _getTopCategory(r);
    final style = AppTheme.categoryStyles[topCat] ?? AppTheme.categoryStyles['Other']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              image: r.imageUrl != null
                  ? DecorationImage(image: NetworkImage(r.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: r.imageUrl == null ? Icon(style.icon, size: 20, color: style.color) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.merchant, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  '${DateFormat('HH:mm').format(r.savedAt)} · ${r.items.length} items · $topCat',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text('-$cur${r.total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all scanned receipts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  String _getTopCategory(Receipt r) {
    if (r.items.isEmpty) return 'Other';
    final cats = <String, double>{};
    for (var i in r.items) {
      cats[i.category] = (cats[i.category] ?? 0) + i.price;
    }
    final sorted = cats.entries.toList();
    sorted.sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }
}
