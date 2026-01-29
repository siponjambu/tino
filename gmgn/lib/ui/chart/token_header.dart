import 'package:flutter/material.dart';
import '../../data/models/dex_pair.dart';

class TokenHeader extends StatelessWidget {
  final DexPair pair;

  const TokenHeader({super.key, required this.pair});

  String _fmt(double v) {
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(2)}K';
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${pair.baseSymbol}/${pair.quoteSymbol}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${pair.priceUsd.toStringAsFixed(6)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item('MC', _fmt(pair.fdv)),
              _item('Liq', _fmt(pair.liquidityUsd)),
              _item('Vol 24h', _fmt(pair.volume24h)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 14)),
      ],
    );
  }
}