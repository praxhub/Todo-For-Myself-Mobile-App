import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mytodo/features/settings/presentation/controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile.adaptive(
                title: const Text('Dark mode'),
                subtitle:
                    const Text('Use a darker theme to reduce eye strain.'),
                value: settingsController.isDarkModeEnabled,
                onChanged: settingsController.setDarkModeEnabled,
              ),
              const Divider(),
              SwitchListTile.adaptive(
                title: const Text('Push Notifications'),
                subtitle:
                    const Text('Receive reminders for habits and due tasks.'),
                value: settingsController.isNotificationsEnabled,
                onChanged: settingsController.setNotificationsEnabled,
              ),
              if (settingsController.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  settingsController.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
