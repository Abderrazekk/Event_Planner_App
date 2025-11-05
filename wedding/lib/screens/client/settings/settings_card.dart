import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wedding/services/auth_service.dart';
import 'package:wedding/providers/theme_provider.dart';

class SettingsCard extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsCard({super.key, required this.onClose});

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await AuthService.logout();
      Navigator.pushReplacementNamed(context, '/Login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.purple),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                themeProvider.setTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
                onClose();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.orange),
            title: const Text('Language Selection'),
            onTap: () {
              // Handle language selection
              onClose();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.green),
            title: const Text('Help & Support'),
            onTap: () {
              onClose();
              Navigator.pushNamed(context, '/help-support');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.blue),
            title: const Text('Terms & Conditions'),
            onTap: () {
              onClose();
              Navigator.pushNamed(context, '/terms');
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.teal),
            title: const Text('Privacy Policy'),
            onTap: () {
              onClose();
              Navigator.pushNamed(context, '/privacy');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
