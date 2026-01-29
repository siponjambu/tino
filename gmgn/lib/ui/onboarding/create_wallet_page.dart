import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/crypto/mnemonic.dart';
import '../../core/storage/secure_storage.dart';
import '../../state/wallet_provider.dart';
import 'confirm_mnemonic_page.dart';

class CreateWalletPage extends ConsumerStatefulWidget {
  const CreateWalletPage({super.key});

  @override
  ConsumerState<CreateWalletPage> createState() =>
      _CreateWalletPageState();
}

class _CreateWalletPageState
    extends ConsumerState<CreateWalletPage> {
  late final String _mnemonic;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _mnemonic = MnemonicService.generate();
  }

  Future<void> _continue() async {
    if (!_confirmed) return;

    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmMnemonicPage(
          mnemonic: _mnemonic,
        ),
      ),
    );

    /// âŒ User cancel / back
    if (confirmed != true) return;

    /// âœ… SIMPAN SEED KE SECURE STORAGE
    await SecureStorage.saveSeed(_mnemonic);

    /// ðŸ”„ FORCE REFRESH WALLET
    ref.read(walletRefreshProvider.notifier).state++;

    if (!mounted) return;

    /// ðŸ”¥ MASUK HOME (CLEAR STACK)
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = _mnemonic.split(' ');

    return Scaffold(
      appBar: AppBar(title: const Text('Create Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Write down these 12 words in order.\n'
              'They are the ONLY way to recover your wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// ðŸ” MNEMONIC GRID
            Expanded(
              child: GridView.builder(
                itemCount: words.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, i) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      '${i + 1}. ${words[i]}',
                      style:
                          const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),

            Row(
              children: [
                Checkbox(
                  value: _confirmed,
                  onChanged: (v) =>
                      setState(() => _confirmed = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I have written down my recovery phrase',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _confirmed ? _continue : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}