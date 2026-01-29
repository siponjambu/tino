import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await SecureStorage.clearSeed();
            Navigator.pop(context);
          },
          child: const Text('Clear Wallet'),
        ),
      ),
    );
  }
}