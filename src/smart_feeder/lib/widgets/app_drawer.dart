import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/constants/app_constants.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/views/settings_view.dart';
import '../view_models/auth_view_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark ? AppTheme.cyberGreen : Colors.black;

    return Drawer(
      backgroundColor: drawerBg,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.cyberGreen.withValues(alpha: 0.2))),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, color: AppTheme.cyberGreen, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    '${AppConstants.appName} ${AppConstants.appVersion}',
                    style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.dashboard, 'Dashboard', true, () {
             Navigator.pop(context);
          }),
          _buildDrawerItem(context, Icons.history, 'Feeding History', false, () {}),
          _buildDrawerItem(context, Icons.settings, 'Settings', false, () {
             Navigator.of(context).push(
               MaterialPageRoute(builder: (context) => const SettingsView()),
             );
          }),
          const Spacer(),
          _buildDrawerItem(context, Icons.logout, 'Logout', false, () {
            context.read<AuthViewModel>().logout();
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, bool selected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppTheme.cyberGreen;
    final inactiveColor = isDark ? Colors.grey : Colors.black54;

    return ListTile(
      leading: Icon(icon, color: selected ? activeColor : inactiveColor),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? activeColor : inactiveColor, 
          fontWeight: selected ? FontWeight.bold : FontWeight.normal
        ),
      ),
      onTap: onTap,
    );
  }
}
