import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmgn/data/jupiter_api.dart';
import 'package:gmgn/state/wallet_provider.dart';
import '../chart/dex_chart_page.dart';

class SwapPage extends ConsumerStatefulWidget {
  final String? presetMint;
  final double? presetAmount;
  final bool isSell;

  const SwapPage({
    super.key,
    this.presetMint,
    this.presetAmount,
    this.isSell = false,
  });

  @override
  ConsumerState<SwapPage> createState() => _SwapPageState();
}

class _SwapPageState extends ConsumerState<SwapPage> {
  bool _loading = false;
  String _status = '';

  static const String SOL_MINT =
      'So11111111111111111111111111111111111111112';
  static const String USDC_MINT =
      'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

  late final String inputMint;
  late final String outputMint;
  late final double amount;

  @override
  void initState() {
    super.initState();

    amount = widget.presetAmount ?? 0.01;

    if (widget.presetMint == null) {
      inputMint = SOL_MINT;
      outputMint = USDC_MINT;
    } else if (widget.isSell) {
      inputMint = widget.presetMint!;
      outputMint = SOL_MINT;
    } else {
      inputMint = SOL_MINT;
      outputMint = widget.presetMint!;
    }
  }

  Future<void> _swap() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _status = 'Requesting quote...';
    });

    try {
      final txNotifier =
          ref.read(walletTxProvider.notifier);
      final publicKey =
          await ref.read(walletProvider.future);

      final int rawAmount = inputMint == SOL_MINT
          ? (amount * 1e9).round()
          : amount.round();

      /// 1ï¸âƒ£ QUOTE
      final quote = await JupiterApi.quote(
        inputMint: inputMint,
        outputMint: outputMint,
        amount: rawAmount,
        slippageBps: 50, // 0.5%
      );

      setState(() => _status = 'Building transaction...');

      /// 2ï¸âƒ£ BUILD TX (BASE64)
      final base64Tx =
          await JupiterApi.buildSwapTransaction(
        quoteResponse: quote,
        userPublicKey: publicKey,
      );

      setState(() => _status = 'Sending transaction...');

      /// 3ï¸âƒ£ SIGN + SEND (wallet_provider)
      await txNotifier.signAndSendSwap(base64Tx);

      setState(() {
        _status = 'Swap success';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Swap failed: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.presetMint == null
        ? 'Chart + Swap'
        : widget.isSell
            ? 'Quick Sell'
            : 'Quick Buy';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: DexChartPage(
              pairPath:
                  'solana/${widget.presetMint ?? inputMint}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  widget.presetMint == null
                      ? 'Swap $amount SOL â†’ USDC'
                      : widget.isSell
                          ? 'Sell $amount'
                          : 'Buy with $amount SOL',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _swap,
                  child: Text(
                      _loading ? 'Processing...' : 'Swap Now'),
                ),
                const SizedBox(height: 8),
                Text(
                  _status,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}