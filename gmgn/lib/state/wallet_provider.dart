import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/solana.dart';

import '../core/storage/secure_storage.dart';
import '../core/crypto/keypair.dart';
import '../core/solana/solana_service.dart';

/// ================= SEED =================

final seedProvider = FutureProvider<String?>((ref) async {
  return SecureStorage.loadSeed();
});

/// ================= KEYPAIR =================

final keypairProvider = FutureProvider<Ed25519HDKeyPair>((ref) async {
  final seed = await ref.watch(seedProvider.future);

  if (seed == null || seed.isEmpty) {
    throw Exception('Wallet seed not found');
  }

  return KeypairService.fromMnemonic(seed);
});

/// ================= WALLET ADDRESS =================

final walletProvider = FutureProvider<String>((ref) async {
  final keypair = await ref.watch(keypairProvider.future);
  return keypair.publicKey.toBase58();
});

/// ================= MANUAL REFRESH =================

final walletRefreshProvider = StateProvider<int>((ref) => 0);

/// ================= SOL BALANCE =================

final solBalanceLamportsProvider = FutureProvider<int>((ref) async {
  ref.watch(walletRefreshProvider);

  final address = await ref.watch(walletProvider.future);

  final balance = await SolanaService.client.rpcClient.getBalance(
    address,
    commitment: Commitment.confirmed,
  );

  return balance.value;
});

final solBalanceProvider = FutureProvider<double>((ref) async {
  final lamports = await ref.watch(solBalanceLamportsProvider.future);
  return lamports / lamportsPerSol;
});

/// ================= TOKEN LIST =================
/// COMPATIBLE solana ^0.32
/// RPC parsed version

final tokenListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(walletRefreshProvider);

  final address = await ref.watch(walletProvider.future);

  final tokens = await SolanaService.getTokenAccounts(address);

  return tokens.where((token) {
    final parsed = token['parsed'];
    if (parsed == null) return false;

    final info = parsed['info'];
    final amount = info?['tokenAmount']?['uiAmount'];

    if (amount == null) return false;
    if (amount is num && amount <= 0) return false;

    return true;
  }).toList();
});

/// ================= TX STATE =================

class WalletTxState {
  final bool sending;
  final String? lastTx;
  final String? error;

  const WalletTxState({
    this.sending = false,
    this.lastTx,
    this.error,
  });

  WalletTxState copyWith({
    bool? sending,
    String? lastTx,
    String? error,
  }) {
    return WalletTxState(
      sending: sending ?? this.sending,
      lastTx: lastTx ?? this.lastTx,
      error: error,
    );
  }
}

/// ================= TX NOTIFIER =================

final walletTxProvider =
    StateNotifierProvider<WalletTxNotifier, WalletTxState>(
  (ref) => WalletTxNotifier(ref),
);

class WalletTxNotifier extends StateNotifier<WalletTxState> {
  final Ref ref;

  WalletTxNotifier(this.ref) : super(const WalletTxState());

  /// Jupiter tx sudah dibuild
  /// Wallet hanya sign + kirim

  Future<void> signAndSendSwap(String base64Tx) async {
    if (base64Tx.isEmpty) {
      throw Exception('Invalid Jupiter transaction');
    }

    if (state.sending) return;

    state = state.copyWith(
      sending: true,
      lastTx: null,
      error: null,
    );

    try {
      final keypair = await ref.read(keypairProvider.future);

      final signature = await SolanaService.signAndSendJupiterSwap(
        base64Tx: base64Tx,
        keypair: keypair,
      );

      ref.read(walletRefreshProvider.notifier).state++;

      state = state.copyWith(
        sending: false,
        lastTx: signature,
      );
    } catch (e) {
      state = state.copyWith(
        sending: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}