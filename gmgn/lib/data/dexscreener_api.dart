import 'dart:async';
import 'package:dio/dio.dart';

class DexscreenerApi {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      responseType: ResponseType.json,

      // ðŸ”¥ FIX PENTING: jangan throw untuk 401/403/429
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  /* ================= TOP SOLANA PAIRS ================= */

  static Future<List<dynamic>> getSolanaPairs() async {
    try {
      final res = await _dio.get(
        'https://api.dexscreener.com/latest/dex/pairs/solana',
      );

      // âœ… guard status
      if (res.statusCode != 200) {
        return const [];
      }

      final data = res.data;
      if (data is Map && data['pairs'] is List) {
        return List<dynamic>.from(data['pairs']);
      }
    } catch (_) {
      // silent fail (tidak ganggu swap)
    }

    return const [];
  }

  /* ================= SEARCH PAIRS ================= */

  static Future<List<dynamic>> searchPairs(String query) async {
    if (query.isEmpty) return const [];

    try {
      final res = await _dio.get(
        'https://api.dexscreener.com/latest/dex/search',
        queryParameters: {'q': query},
      );

      // âœ… guard status
      if (res.statusCode != 200) {
        return const [];
      }

      final data = res.data;
      if (data is Map && data['pairs'] is List) {
        return List<dynamic>.from(data['pairs']);
      }
    } catch (_) {
      // silent fail
    }

    return const [];
  }

  /* ================= OPTIONAL: SAFE RETRY ================= */

  static Future<List<dynamic>> retry(
    Future<List<dynamic>> Function() fn, {
    int retries = 2,
  }) async {
    for (var i = 0; i <= retries; i++) {
      final result = await fn();
      if (result.isNotEmpty) return result;
      await Future.delayed(const Duration(milliseconds: 400));
    }
    return const [];
  }
}