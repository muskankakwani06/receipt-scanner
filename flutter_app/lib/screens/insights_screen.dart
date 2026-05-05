import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cur = provider.settings.currency;
    final totalSpent = provider.receipts.fold(0.0, (sum, r) => sum + r.total);
    final categoryTotals = provider.categoryTotals;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
            SizedBox(width: 12),
            Text('Receipt Scanner +', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalCard(totalSpent, provider.receipts.length, cur),
            const SizedBox(height: 32),
            const Text('Spending by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCategoryList(categoryTotals, totalSpent, cur),
            const SizedBox(height: 32),
            const Text('Top Merchants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMerchantList(provider, cur),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total, int count, String cur) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF5C9EFF)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Tracked', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('$cur${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$count receipts scanned', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCategoryList(Map<String, double> totals, double overallTotal, String cur) {
    if (totals.isEmpty) return _buildEmptyState(LucideIcons.barChart2, 'No data yet');

    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxTotal = overallTotal > 0 ? overallTotal : 1.0;

    return Column(
      children: sorted.map((e) {
        final style = AppTheme.categoryStyles[e.key] ?? AppTheme.categoryStyles['Other']!;
        final progress = e.value / maxTotal;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: style.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(style.icon, size: 20, color: style.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                        Text('$cur${e.value.toStringAsFixed(2)}', style: TextStyle(color: style.color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(style.color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMerchantList(AppProvider provider, String cur) {
    final Map<String, _MerchantData> merchants = {};
    for (var r in provider.receipts) {
      final name = r.merchant;
      merchants.putIfAbsent(name, () => _MerchantData(name: name, total: 0, count: 0));
      merchants[name]!.total += r.total;
      merchants[name]!.count++;
    }

    if (merchants.isEmpty) return _buildEmptyState(LucideIcons.store, 'No merchants yet');

    final sorted = merchants.values.toList()..sort((a, b) => b.total.compareTo(a.total));

    return Column(
      children: sorted.take(5).map((m) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(m.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  Text('${m.count} visits', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text('$cur${m.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState(IconData icon, String label) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MerchantData {
  final String name;
  double total;
  int count;
  _MerchantData({required this.name, required this.total, required this.count});
}
