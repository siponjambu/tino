import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:solana/solana.dart';

class SolanaService {
  static final String _rpcUrl = dotenv.env['ALCHEMY_SOLANA_RPC']!;

  static final SolanaClient _client = SolanaClient(
    rpcUrl: Uri.parse(_rpcUrl),
    websocketUrl: Uri.parse('wss://api.mainnet-beta.solana.com'),
  );

  static SolanaClient get client => _client;

  // =============================================================
  // SEND SOL
  // =============================================================

  static Future<String> sendSol({
    required Ed25519HDKeyPair signer,
    required String to,
    required int lamports,
  }) async {
    final recipient = Ed25519HDPublicKey.fromBase58(to);

    final instruction = SystemInstruction.transfer(
      fundingAccount: signer.publicKey,
      recipientAccount: recipient,
      lamports: lamports,
    );

    final message = Message.only(instruction);

    final sig = await client.rpcClient.signAndSendTransaction(
      message,
      [signer],
      commitment: Commitment.confirmed,
    );

    await _waitForConfirmed(sig);

    return sig;
  }

  // =============================================================
// JUPITER SIGN + SEND (VERSIONED TX)
// =============================================================

static Future<String> signAndSendJupiterSwap({
  required String base64Tx,
  required Ed25519HDKeyPair keypair,
}) async {
  // decode base64 tx dari Jupiter
  final raw = base64.decode(base64Tx);

  // deserialize versioned tx
  final tx = VersionedTransaction.deserialize(raw);

  // sign pakai wallet
  tx.sign([keypair]);

  // kirim ke RPC
  final signature = await client.rpcClient.sendTransaction(
    base64.encode(tx.serialize()),
    preflightCommitment: Commitment.confirmed,
  );

  await _waitForConfirmed(signature);

  return signature;
}

  // =============================================================
  // TOKEN ACCOUNTS
  // =============================================================

  static Future<List<Map<String, dynamic>>> getTokenAccounts(
    String owner,
  ) async {
    final res = await client.rpcClient.getTokenAccountsByOwner(
      owner,
      const TokenAccountsFilter.byProgramId(
        TokenProgram.programId,
      ),
    );

    return res.value
        .map((e) => e.account.data as Map<String, dynamic>)
        .toList();
  }

  // =============================================================
  // BALANCE
  // =============================================================

  static Future<int> getSolBalanceLamports(String address) async {
    final res = await client.rpcClient.getBalance(
      address,
      commitment: Commitment.confirmed,
    );

    return res.value;
  }

  // =============================================================
  // CONFIRM LOOP
  // =============================================================

  static Future<void> _waitForConfirmed(
    String signature, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final start = DateTime.now();

    while (true) {
      final res =
          await client.rpcClient.getSignatureStatuses([signature]);

      final status = res.value.first;

      if (status != null) {
        if (status.err != null) {
          throw Exception('Transaction failed: ${status.err}');
        }

        if (status.confirmationStatus ==
                Commitment.confirmed ||
            status.confirmationStatus ==
                Commitment.finalized) {
          return;
        }
      }

      if (DateTime.now().difference(start) > timeout) {
        throw Exception('Transaction timeout');
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }
}