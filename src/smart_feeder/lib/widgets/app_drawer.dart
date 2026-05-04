import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/constants/app_constants.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import '../view_models/auth_view_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.cyberGreen.withValues(alpha: 0.2))),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, color: AppTheme.cyberGreen, size: 40),
                  SizedBox(height: 10),
                  Text(
                    '${AppConstants.appName} ${AppConstants.appVersion}',
                    style: TextStyle(color: AppTheme.cyberGreen, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', true, () {}),
          _buildDrawerItem(Icons.history, 'Feeding History', false, () {}),
          _buildDrawerItem(Icons.settings, 'Settings', false, () {}),
          const Spacer(),
          _buildDrawerItem(Icons.logout, 'Logout', false, () {
            context.read<AuthViewModel>().logout();
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool selected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.cyberGreen : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppTheme.cyberGreen : Colors.grey, 
          fontWeight: selected ? FontWeight.bold : FontWeight.normal
        ),
      ),
      onTap: onTap,
    );
  }
}
