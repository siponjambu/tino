import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmgn/data/jupiter_api.dart';
import 'package:gmgn/state/wallet_provider.dart';

const String SOL_MINT =
    'So11111111111111111111111111111111111111112';

class QuickTradeBar extends ConsumerWidget {
  final int tokenBalance;
  final String tokenMint;

  const QuickTradeBar({
    super.key,
    required this.tokenMint,
    required this.tokenBalance,
  });

  String _cleanError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception:')
        ? msg.replaceFirst('Exception:', '').trim()
        : msg;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(walletTxProvider);

    /* ================= BUY ================= */
    Future<void> _buy(double sol) async {
      final txNotifier = ref.read(walletTxProvider.notifier);
      if (txNotifier.state.sending) return;

      try {
        if (tokenMint.isEmpty) {
          throw Exception('Invalid token mint');
        }

        final publicKey = await ref.read(walletProvider.future);

        final lamports = (sol * 1e9).floor();
        if (lamports <= 0) {
          throw Exception('Invalid SOL amount');
        }

        final quote = await JupiterApi.quote(
          inputMint: SOL_MINT,
          outputMint: tokenMint,
          amount: lamports,
          slippageBps: 5000, // 50%
        );

        if (quote['routePlan'] is! List ||
            quote['routePlan'].isEmpty) {
          throw Exception('No route found');
        }

        final swapTx =
            await JupiterApi.buildSwapTransaction(
          quoteResponse: quote,
          userPublicKey: publicKey,
        );

        // âœ… SIGN + SEND di wallet_provider
        await txNotifier.signAndSendSwap(swapTx);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Buy transaction sent'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_cleanError(e))),
          );
        }
      }
    }

    /* ================= SELL ================= */
    Future<void> _sell(double percent) async {
      final txNotifier = ref.read(walletTxProvider.notifier);
      if (txNotifier.state.sending) return;

      try {
        if (tokenMint.isEmpty || tokenMint == SOL_MINT) {
          throw Exception('Invalid sell token');
        }

        if (tokenBalance <= 0) {
          throw Exception('No token balance');
        }

        final publicKey = await ref.read(walletProvider.future);

        final amount = (tokenBalance * percent).floor();
        if (amount <= 0) {
          throw Exception('Invalid sell amount');
        }

        final quote = await JupiterApi.quote(
          inputMint: tokenMint,
          outputMint: SOL_MINT,
          amount: amount,
          slippageBps: 5000, // 50%
        );

        if (quote['routePlan'] is! List ||
            quote['routePlan'].isEmpty) {
          throw Exception('No route found');
        }

        final swapTx =
            await JupiterApi.buildSwapTransaction(
          quoteResponse: quote,
          userPublicKey: publicKey,
        );

        // âœ… SIGN + SEND di wallet_provider
        await txNotifier.signAndSendSwap(swapTx);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sell transaction sent'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_cleanError(e))),
          );
        }
      }
    }

    final disabled =
        txState.sending || tokenMint.isEmpty;

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn('0.01', () => _buy(0.01), disabled: disabled),
            _btn('0.02', () => _buy(0.02), disabled: disabled),
            _btn('0.05', () => _buy(0.05), disabled: disabled),
            _btn('0.07', () => _buy(0.07), disabled: disabled),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn('25%', () => _sell(0.25),
                disabled: disabled || tokenBalance <= 0),
            _btn('50%', () => _sell(0.5),
                disabled: disabled || tokenBalance <= 0),
            _btn('100%', () => _sell(1.0),
                disabled: disabled || tokenBalance <= 0),
          ],
        ),
      ],
    );
  }

  Widget _btn(
    String text,
    VoidCallback onTap, {
    bool disabled = false,
  }) {
    return ElevatedButton(
      onPressed: disabled ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            disabled ? Colors.grey.shade800 : Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }
}