import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JupiterApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.jup.ag',
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'MySolanaWallet/1.0',
        if (dotenv.env['JUPITER_API_KEY'] != null &&
            dotenv.env['JUPITER_API_KEY']!.isNotEmpty)
          'x-api-key': dotenv.env['JUPITER_API_KEY'],
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 500,
    ),
  );

  // =============================================================
  // QUOTE
  // =============================================================

  static Future<Map<String, dynamic>> quote({
    required String inputMint,
    required String outputMint,
    required int amount,
    int slippageBps = 500,
  }) async {
    final res = await _dio.get(
      '/swap/v1/quote',
      queryParameters: {
        'inputMint': inputMint,
        'outputMint': outputMint,
        'amount': amount,
        'slippageBps': slippageBps,
        'swapMode': 'ExactIn',
        'onlyDirectRoutes': false,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Jupiter quote error: ${res.data}');
    }

    return Map<String, dynamic>.from(res.data);
  }

  // =============================================================
  // BUILD SWAP TX (LEGACY)
  // =============================================================

  static Future<String> buildSwapTransaction({
    required Map<String, dynamic> quoteResponse,
    required String userPublicKey,
  }) async {
    final res = await _dio.post(
      '/swap/v1/swap',
      data: {
        'quoteResponse': quoteResponse,
        'userPublicKey': userPublicKey,

        'wrapAndUnwrapSol': true,
        'allowCreateATA': true,

        // 🔥 wajib utk flutter solana ^0.32
        'asLegacyTransaction': true,
        'dynamicComputeUnitLimit': false,

        // priority fee (lebih stabil)
        'computeUnitPriceMicroLamports': 2000,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Jupiter swap error: ${res.data}');
    }

    final data = Map<String, dynamic>.from(res.data);

    final tx = data['swapTransaction'];

    if (tx == null || tx is! String) {
      throw Exception('Jupiter returned empty transaction');
    }

    return tx;
  }
}