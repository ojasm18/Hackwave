import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  final void Function(String role) onRoleSelected;
  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    final roles = [
      {'label': 'Organizer', 'icon': Icons.event},
      {'label': 'Attendee', 'icon': Icons.person},
      {'label': 'Vendor', 'icon': Icons.store},
      {'label': 'Sponsor', 'icon': Icons.business},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Choose your role to continue:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ...roles.map((role) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(role['icon'] as IconData),
                label: Text(role['label'] as String),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => onRoleSelected(role['label'] as String),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
