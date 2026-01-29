import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/models/dex_pair.dart';
import '../../data/services/dexscreener_service.dart';
import '../../state/wallet_provider.dart';
import '../swap/quick_trade_bar.dart';
import 'token_header.dart';

class DexChartPage extends ConsumerStatefulWidget {
  final String pairPath;

  const DexChartPage({
    super.key,
    required this.pairPath,
  });

  @override
  ConsumerState<DexChartPage> createState() => _DexChartPageState();
}

class _DexChartPageState extends ConsumerState<DexChartPage> {
  DexPair? pair;
  late final WebViewController _controller;

  bool _isFullscreen = false;
  bool _pairLoadFailed = false;

  @override
  void initState() {
    super.initState();

    /// SAFE SPLIT pairPath
    final parts = widget.pairPath.split('/');
    if (parts.length == 2) {
      _loadPair(parts[0], parts[1]);
    } else {
      _pairLoadFailed = true;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          'https://dexscreener.com/${widget.pairPath}?embed=1&theme=dark&info=0',
        ),
      );
  }

  Future<void> _loadPair(String chainId, String pairAddress) async {
    final res = await DexscreenerService.getPairDetail(
      chainId,
      pairAddress,
    );

    if (!mounted) return;

    setState(() {
      pair = res;
      _pairLoadFailed = res == null;
    });
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);

    SystemChrome.setEnabledSystemUIMode(
      _isFullscreen
          ? SystemUiMode.immersiveSticky
          : SystemUiMode.edgeToEdge,
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// ðŸ”¥ Token accounts (RAW on-chain)
    final tokenListAsync = ref.watch(tokenListProvider);

    /// Cari RAW balance token berdasarkan mint
    int _resolveRawTokenBalance() {
      if (pair == null) return 0;

      return tokenListAsync.when(
        data: (tokens) {
          for (final t in tokens) {
            final info =
                t['account']?['data']?['parsed']?['info'];
            if (info == null) continue;

            if (info['mint'] == pair!.baseMint) {
              final amount =
                  info['tokenAmount']?['amount'];
              return int.tryParse(amount ?? '0') ?? 0;
            }
          }
          return 0;
        },
        loading: () => 0,
        error: (_, __) => 0,
      );
    }

    final rawTokenBalance = _resolveRawTokenBalance();

    return Scaffold(
      backgroundColor: Colors.black,

      /// APPBAR HILANG SAAT FULLSCREEN
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              title: const Text('Chart'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullscreen,
                ),
              ],
            ),

      body: SafeArea(
        top: !_isFullscreen,
        bottom: !_isFullscreen,
        child: Column(
          children: [
            /// HEADER
            if (!_isFullscreen && pair != null)
              TokenHeader(pair: pair!),

            /// ERROR STATE
            if (!_isFullscreen && pair == null && _pairLoadFailed)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Pair data not available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            /// CHART
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isFullscreen)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(
                          Icons.fullscreen_exit,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFullscreen,
                      ),
                    ),
                ],
              ),
            ),

            /// QUICK BUY / SELL
            if (!_isFullscreen &&
                pair != null &&
                pair!.baseMint.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: QuickTradeBar(
                  tokenMint: pair!.baseMint,
                  /// ðŸ”¥ RAW on-chain amount
                  tokenBalance: rawTokenBalance,
                ),
              ),
          ],
        ),
      ),
    );
  }
}