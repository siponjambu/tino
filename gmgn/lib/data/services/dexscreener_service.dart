import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/dex_pair.dart';

class DexscreenerService {
  static const String _baseUrl = 'https://api.dexscreener.com/latest';

  /* ===============================
   * SEARCH TOKEN (PAIR / SYMBOL)
   * =============================== */
  static Future<List<DexPair>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl/dex/search?q=${Uri.encodeQueryComponent(q)}',
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final List list =
          (data is Map && data['pairs'] is List) ? data['pairs'] : [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => DexPair.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /* ===============================
   * Ã°Å¸â€Â¥ SEARCH BY TOKEN MINT (GMGN / PHANTOM STYLE)
   * =============================== */
  static Future<List<DexPair>> searchByMint(String mint) async {
    final m = mint.trim();
    if (m.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl/dex/tokens/${Uri.encodeComponent(m)}',
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final List list =
          (data is Map && data['pairs'] is List) ? data['pairs'] : [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => DexPair.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /* ===============================
   * Ã°Å¸â€Â FALLBACK (PHANTOM-LIKE SEARCH)
   * DIGUNAKAN OLEH market_provider.dart
   * =============================== */
  static Future<List<DexPair>> searchTokenLikePhantom(
    String query,
  ) async {
    // kalau panjang >= 32 Ã¢â€ â€™ kemungkinan MINT
    if (query.length >= 32) {
      final byMint = await searchByMint(query);
      if (byMint.isNotEmpty) return byMint;
    }

    // fallback ke search biasa
    return search(query);
  }

  /* ===============================
   * SINGLE PAIR DETAIL (TOKEN HEADER)
   * =============================== */
  static Future<DexPair?> getPairDetail(
    String chainId,
    String pairAddress,
  ) async {
    if (chainId.isEmpty || pairAddress.isEmpty) return null;

    try {
      final uri = Uri.parse(
        '$_baseUrl/dex/pairs/$chainId/$pairAddress',
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final List pairs =
          (data is Map && data['pairs'] is List) ? data['pairs'] : [];

      if (pairs.isEmpty) return null;

      return DexPair.fromJson(
        Map<String, dynamic>.from(pairs.first),
      );
    } catch (_) {
      return null;
    }
  }

  /* ===============================
   * REALTIME / TRENDING TOKEN (SOLANA)
   * =============================== */
  static Future<List<DexPair>> fetchTrendingSolana() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/dex/pairs/solana',
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final List list =
          (data is Map && data['pairs'] is List) ? data['pairs'] : [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => DexPair.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }
}