import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/crypto/mnemonic.dart';
import '../../core/storage/secure_storage.dart';
import '../home/home_page.dart';

class ImportWalletPage extends ConsumerStatefulWidget {
  const ImportWalletPage({super.key});

  @override
  ConsumerState<ImportWalletPage> createState() =>
      _ImportWalletPageState();
}

class _ImportWalletPageState
    extends ConsumerState<ImportWalletPage> {
  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _import() async {
    final text = _controller.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    final words = text.split(' ');

    if (words.length != 12 && words.length != 24) {
      setState(() {
        _error = 'Mnemonic must be 12 or 24 words';
      });
      return;
    }

    if (!MnemonicService.validate(text)) {
      setState(() {
        _error = 'Invalid recovery phrase';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      /// ðŸ” SAVE SEED (CRITICAL IN RELEASE)
      await SecureStorage.saveSeed(text);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to save wallet securely';
      });
      return;
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Enter your 12 or 24 word recovery phrase.\n'
              'Words must be in the correct order.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              maxLines: 4,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                hintText: 'word1 word2 word3 ...',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _import,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Import Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}