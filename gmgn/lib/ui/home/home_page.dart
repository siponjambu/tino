import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/wallet_provider.dart';
import '../../state/market_provider.dart';
import '../send/send_page.dart';
import '../swap/swap_page.dart';
import '../settings/settings_page.dart';
import '../onboarding/onboarding_page.dart';
import 'token_search_bar.dart';
import 'market_list_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _tokenLogoUrl(String mint) {
    return 'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/$mint/logo.png';
  }

  String _formatSol(double sol) {
    if (sol == 0) return '0';
    if (sol < 0.001) return sol.toStringAsPrecision(2);
    return sol.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seedAsync = ref.watch(seedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solana Wallet'),
        centerTitle: true,
      ),
      body: seedAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e.toString())),
        data: (seed) {
          if (seed == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingPage(),
                ),
              );
            });
            return const SizedBox.shrink();
          }

          final walletAsync = ref.watch(walletProvider);
          final solBalanceAsync = ref.watch(solBalanceProvider);
          final tokenListAsync = ref.watch(tokenListProvider);
          final marketState = ref.watch(marketProvider);

          return walletAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(e.toString())),
            data: (address) {
              return Column(
                children: [
                  // ===== BALANCE CARD =====
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            SelectableText(
                              address,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            solBalanceAsync.when(
                              loading: () =>
                                  const CircularProgressIndicator(strokeWidth: 2),
                              error: (_, __) =>
                                  const Text('Balance unavailable'),
                              data: (solBalance) => Text(
                                '${_formatSol(solBalance)} SOL',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const TokenSearchBar(),
                  const SizedBox(height: 8),

                  // ===== TOKEN LIST =====
                  Expanded(
                    child: marketState.tokens.isNotEmpty ||
                            marketState.loading
                        ? marketState.loading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const MarketListView()
                        : tokenListAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, __) =>
                                const Center(child: Text('Token load failed')),
                            data: (tokens) {
                              if (tokens.isEmpty) {
                                return const Center(
                                  child: Text('No tokens found'),
                                );
                              }

                              return ListView.builder(
                                itemCount: tokens.length + 1,
                                itemBuilder: (context, i) {
                                  // ===== SOL ROW =====
                                  if (i == 0) {
                                    return ListTile(
                                      leading: Image.network(
                                        'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
                                        width: 32,
                                        height: 32,
                                      ),
                                      title: const Text('SOL'),
                                      trailing: solBalanceAsync.when(
                                        loading: () =>
                                            const SizedBox.shrink(),
                                        error: (_, __) =>
                                            const Text('-'),
                                        data: (sol) =>
                                            Text(_formatSol(sol)),
                                      ),
                                    );
                                  }

                                  final t = tokens[i - 1];
                                  final info = t['account']?['data']
                                      ?['parsed']?['info'];
                                  if (info == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final mint =
                                      info['mint']?.toString() ?? '';
                                  final amount =
                                      info['tokenAmount']
                                              ?['uiAmountString']
                                          ?.toString() ??
                                          '0';

                                  return ListTile(
                                    leading: Image.network(
                                      _tokenLogoUrl(mint),
                                      width: 32,
                                      height: 32,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const Icon(Icons.token),
                                    ),
                                    title: Text(
                                      '${mint.substring(0, 6)}...${mint.substring(mint.length - 4)}',
                                    ),
                                    trailing: Text(amount),
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  // ===== ACTION BUTTONS =====
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SendPage(),
                            ),
                          ),
                          child: const Text('Send'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SwapPage(),
                            ),
                          ),
                          child: const Text('Swap'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          ),
                          child: const Text('Settings'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}