class DexPair {
  final String chainId;
  final String dexId;
  final String pairAddress;

  // ðŸ”¥ TOKEN INFO
  final String baseSymbol;
  final String baseMint; // âœ… WAJIB UNTUK QUICK BUY / SELL
  final String quoteSymbol;

  final double priceUsd;
  final double liquidityUsd;

  /// Market data
  final double fdv;        // Market Cap / FDV
  final double volume24h;  // Volume 24 jam

  DexPair({
    required this.chainId,
    required this.dexId,
    required this.pairAddress,
    required this.baseSymbol,
    required this.baseMint,
    required this.quoteSymbol,
    required this.priceUsd,
    required this.liquidityUsd,
    this.fdv = 0,
    this.volume24h = 0,
  });

  factory DexPair.fromJson(Map<String, dynamic> json) {
    // ðŸ”’ STRING SAFE (ANTI NULL CRASH)
    String _safeString(dynamic v, {String fallback = '-'}) {
      if (v == null) return fallback;
      final s = v.toString().trim();
      return s.isEmpty ? fallback : s;
    }

    // ðŸ”’ DOUBLE SAFE
    double _toDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    final Map<String, dynamic> baseToken =
        (json['baseToken'] is Map<String, dynamic>)
            ? json['baseToken']
            : <String, dynamic>{};

    final Map<String, dynamic> quoteToken =
        (json['quoteToken'] is Map<String, dynamic>)
            ? json['quoteToken']
            : <String, dynamic>{};

    final Map<String, dynamic> liquidity =
        (json['liquidity'] is Map<String, dynamic>)
            ? json['liquidity']
            : <String, dynamic>{};

    final Map<String, dynamic> volume =
        (json['volume'] is Map<String, dynamic>)
            ? json['volume']
            : <String, dynamic>{};

    return DexPair(
      chainId: _safeString(json['chainId']),
      dexId: _safeString(json['dexId']),
      pairAddress: _safeString(json['pairAddress']),

      baseSymbol: _safeString(baseToken['symbol'], fallback: 'UNKNOWN'),
      baseMint: _safeString(baseToken['address']), // ðŸ”¥ PENTING & AMAN
      quoteSymbol: _safeString(quoteToken['symbol'], fallback: 'TOKEN'),

      priceUsd: _toDouble(json['priceUsd']),
      liquidityUsd: _toDouble(liquidity['usd']),
      fdv: _toDouble(json['fdv']),
      volume24h: _toDouble(volume['h24']),
    );
  }
}