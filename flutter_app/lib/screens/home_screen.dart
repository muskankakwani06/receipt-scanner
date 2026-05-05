import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/receipt.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cur = provider.settings.currency;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(provider),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildBudgetCard(provider, cur),
                  const SizedBox(height: 24),
                  _buildQuickStats(provider, cur),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(provider, cur),
                ]),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 28),
                SizedBox(width: 12),
                Text('Receipt Scanner +', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            GestureDetector(
              onTap: () => provider.setTab(4),
              child: CircleAvatar(
                backgroundColor: AppTheme.primary,
                radius: 20,
                child: Text(
                  provider.userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(AppProvider provider, String cur) {
    final spent = provider.monthlySpent;
    final remaining = provider.remainingBudget;
    final progress = provider.budgetProgress;
    final month = DateFormat('MMMM yyyy').format(DateTime.now());

    return GlassmorphicContainer(
      width: double.infinity,
      height: 190,
      borderRadius: 24,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.02),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Monthly Budget', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                Text(month, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$cur${spent.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      const Text('Spent', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(height: 45, width: 1, color: Colors.white.withOpacity(0.1)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$cur${remaining.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      const Text('Remaining', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress > 0.8 ? AppTheme.danger : (progress > 0.6 ? AppTheme.warning : AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${(progress * 100).toInt()}% used', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(AppProvider provider, String cur) {
    final totals = provider.categoryTotals;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard('Food', totals['Food & Dining'] ?? 0, LucideIcons.utensils, AppTheme.categoryStyles['Food & Dining']!.color, cur),
        _buildStatCard('Transport', totals['Transport'] ?? 0, LucideIcons.car, AppTheme.categoryStyles['Transport']!.color, cur),
        _buildStatCard('Shopping', totals['Shopping'] ?? 0, LucideIcons.shoppingBag, AppTheme.categoryStyles['Shopping']!.color, cur),
        _buildStatCard('Other', (totals['Other'] ?? 0) + (totals.entries.where((e) => !['Food & Dining','Transport','Shopping','Other'].contains(e.key)).fold(0.0, (s, e) => s + e.value)), LucideIcons.package, AppTheme.categoryStyles['Other']!.color, cur),
      ],
    );
  }

  Widget _buildStatCard(String label, double amount, IconData icon, Color color, String cur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$cur${_formatAmount(amount)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(AppProvider provider, String cur) {
    final recent = provider.receipts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(color: AppTheme.primary))),
          ],
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.receipt, size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('No receipts yet', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Scan your first receipt to get started', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = recent[index];
              return _buildTransactionTile(r, cur);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionTile(Receipt r, String cur) {
    final topCat = _getTopCategory(r);
    final style = AppTheme.categoryStyles[topCat] ?? AppTheme.categoryStyles['Other']!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
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
            child: r.imageUrl == null ? Icon(style.icon, color: style.color, size: 20) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.merchant, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  '${DateFormat('d MMM').format(r.date)} · ${r.items.length} items · $topCat',
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

  String _formatAmount(double n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    return n.toStringAsFixed(0);
  }

  static const Color surfaceColor = Color(0xFF111827);
}
