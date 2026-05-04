import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/view_models/theme_view_model.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'delete_account_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, 
            size: 20, 
            color: isDark ? AppTheme.cyberGreen : Colors.black
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionHeader(context, 'APPEARANCE'),
                  SwitchListTile(
                    activeColor: AppTheme.cyberGreen,
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Toggle between dark and light themes', style: TextStyle(fontSize: 12)),
                    value: isDark,
                    onChanged: (value) => themeViewModel.toggleTheme(),
                    secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? AppTheme.cyberGreen : Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, 'ACCOUNT'),
                  _buildSettingsItem(
                    context,
                    Icons.person_outline,
                    'Profile Information',
                    'View and edit your profile',
                    null,
                  ),
                  _buildSettingsItem(
                    context,
                    Icons.notifications_none,
                    'Notifications',
                    'Configure alerts and sounds',
                    null,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'DANGER ZONE'),
                  _buildSettingsItem(
                    context,
                    Icons.delete_forever_outlined,
                    'Delete Account',
                    'Permanently remove your account',
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DeleteAccountView()),
                      );
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black);
    
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: color.withValues(alpha: 0.4), fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.2), size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
