import 'package:flutter/material.dart';

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
              border: Border(bottom: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.2))),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, color: Colors.greenAccent, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Smart Feeder v1.0',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', true),
          _buildDrawerItem(Icons.history, 'Feeding History', false),
          _buildDrawerItem(Icons.settings, 'Settings', false),
          const Spacer(),
          _buildDrawerItem(Icons.logout, 'Logout', false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool selected) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.greenAccent : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.greenAccent : Colors.grey, 
          fontWeight: selected ? FontWeight.bold : FontWeight.normal
        ),
      ),
      onTap: () {},
    );
  }
}
