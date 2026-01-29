import 'package:flutter/material.dart';
import 'create_wallet_page.dart';
import 'import_wallet_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Personal Solana Wallet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateWalletPage(),
                  ),
                );

                // ðŸ”‘ Setelah wallet dibuat â†’ tutup onboarding
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create New Wallet'),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ImportWalletPage(),
                  ),
                );

                // ðŸ”‘ Setelah wallet di-import â†’ tutup onboarding
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Import Existing Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}