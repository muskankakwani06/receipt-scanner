import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final authProvider = context.watch<AuthProvider>();
    final settings = provider.settings;
    final user = authProvider.user;

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
          children: [
            _buildProfileCard(user),
            const SizedBox(height: 32),
            _buildSectionHeader('App Settings'),
            _buildSettingsItem(
              icon: LucideIcons.coins,
              label: 'Monthly Budget',
              value: '${settings.currency}${settings.budget.toStringAsFixed(0)}',
              onTap: () => _showBudgetDialog(context, provider),
            ),
            _buildSettingsItem(
              icon: LucideIcons.key,
              label: 'Gemini API Key',
              value: settings.apiKey.isEmpty ? 'Not Set' : 'Set ✓',
              valueColor: settings.apiKey.isEmpty ? AppTheme.danger : AppTheme.success,
              onTap: () => _showApiKeyDialog(context, provider),
            ),
            _buildSettingsItem(
              icon: LucideIcons.globe,
              label: 'Currency',
              value: settings.currency,
              onTap: () => _showCurrencyDialog(context, provider),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Support'),
            _buildSettingsItem(
              icon: LucideIcons.helpCircle, 
              label: 'Help Center', 
              onTap: () => _showSupportDialog(context, 'Help Center', 'Our support team is here to help! Visit our website or email us at support@receiptscanner.plus'),
            ),
            _buildSettingsItem(
              icon: LucideIcons.shieldCheck, 
              label: 'Privacy Policy', 
              onTap: () => _showSupportDialog(context, 'Privacy Policy', 'Your data is encrypted and securely stored on Firebase. We never share your personal information with third parties.'),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => authProvider.signOut(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Log Out'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Receipt Scanner + v1.0.0', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    String name = 'User';
    String email = 'No email';
    
    if (user is Map) {
      name = user['displayName'] ?? 'User';
      email = user['email'] ?? 'No email';
    } else if (user != null) {
      name = user.displayName ?? 'User';
      email = user.email ?? 'No email';
    }

    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppTheme.primary,
            child: Text(initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.edit3, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    String? value,
    Color? valueColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(value, style: TextStyle(color: valueColor ?? AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.settings.budget.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(prefixText: provider.settings.currency),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) provider.updateBudget(val);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.settings.apiKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your Google Gemini API key. Type "demo" to test without a key.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'AIzaSy...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.updateApiKey(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, AppProvider provider) {
    const currencies = ['₹', r'$', '€', '£', '¥', '₣'];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Currency'),
        children: currencies.map((c) => SimpleDialogOption(
          onPressed: () { provider.updateCurrency(c); Navigator.pop(context); },
          child: Text(c, style: const TextStyle(fontSize: 18)),
        )).toList(),
      ),
    );
  }
}
