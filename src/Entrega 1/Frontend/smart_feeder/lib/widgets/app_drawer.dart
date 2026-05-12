import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/constants/app_constants.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/view_models/theme_view_model.dart';
import 'package:smart_feeder/views/history_view.dart';

/// Drawer lateral de navegação do app.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeVM = context.watch<ThemeViewModel>();

    return Drawer(
      backgroundColor:
          isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F0F0),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.pets, color: AppTheme.cyberGreen, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        AppConstants.appVersion,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Navegação
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.history_outlined,
              label: 'Feeding History',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryView(),
                  ),
                );
              },
            ),

            const Spacer(),
            const Divider(height: 1),

            // Toggle de tema
            ListTile(
              leading: Icon(
                themeVM.themeMode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: Colors.grey,
              ),
              title: Text(
                themeVM.themeMode == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
                style: const TextStyle(fontSize: 14),
              ),
              onTap: () {
                themeVM.toggleTheme();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.cyberGreen),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
