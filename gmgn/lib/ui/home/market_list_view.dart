import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/market_provider.dart';
import '../chart/dex_chart_page.dart';

class MarketListView extends ConsumerWidget {
  const MarketListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketProvider);

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.tokens.isEmpty) {
      return const Center(
        child: Text(
          'No result',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: state.tokens.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade800, height: 1),
      itemBuilder: (context, index) {
        final p = state.tokens[index];

        // ðŸ”’ SAFETY GUARD â€” token tanpa pair JANGAN crash
        final hasPair =
            p.chainId.isNotEmpty && p.pairAddress.isNotEmpty;

        final base =
            p.baseSymbol.isNotEmpty ? p.baseSymbol : 'UNKNOWN';
        final quote =
            p.quoteSymbol.isNotEmpty ? p.quoteSymbol : '';

        final title =
            quote.isEmpty ? base : '$base/$quote';

        final price = p.priceUsd;

        return ListTile(
          dense: true,
          enabled: hasPair, // ðŸ‘ˆ disable tap kalau tidak ada pair
          title: Text(
            title,
            style: TextStyle(
              color: hasPair ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            hasPair
                ? '${p.chainId} â€¢ ${p.dexId}'
                : 'Token not paired yet',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          trailing: Text(
            price > 0 ? '\$${price.toStringAsFixed(6)}' : '-',
            style: TextStyle(
              color: price > 0 ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: hasPair
              ? () {
                  final pairPath =
                      '${p.chainId}/${p.pairAddress}';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DexChartPage(
                        pairPath: pairPath,
                      ),
                    ),
                  );
                }
              : null,
        );
      },
    );
  }
}