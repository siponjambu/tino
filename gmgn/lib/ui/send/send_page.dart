import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/solana/solana_service.dart';
import '../../state/wallet_provider.dart';

class SendPage extends ConsumerStatefulWidget {
  const SendPage({super.key});

  @override
  ConsumerState<SendPage> createState() => _SendPageState();
}

class _SendPageState extends ConsumerState<SendPage> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _loading = false;
  String? status;

  Future<void> _sendSol() async {
    final keypairAsync = ref.read(keypairProvider);

    if (keypairAsync is! AsyncData || keypairAsync.value == null) {
      setState(() {
        status = 'Wallet not ready';
      });
      return;
    }

    // ===============================
    // SAFE CAST KEYPAIR
    // ===============================
    final signer = keypairAsync.value!;

    final to = _toController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (to.isEmpty || amount == null || amount <= 0) {
      setState(() {
        status = 'Invalid address or amount';
      });
      return;
    }

    final lamports = (amount * 1000000000).toInt();

    setState(() {
      _loading = true;
      status = null;
    });

    try {
      final sig = await SolanaService.sendSol(
        signer: signer,
        to: to,
        lamports: lamports,
      );

      // refresh wallet balance
      ref.read(walletRefreshProvider.notifier).state++;

      setState(() {
        status = 'Success: $sig';
      });
    } catch (e) {
      setState(() {
        status = 'Failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send SOL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'Receiver Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (SOL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendSol,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
              ),
            ),
            if (status != null) ...[
              const SizedBox(height: 16),
              Text(
                status!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: status!.startsWith('Success')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}