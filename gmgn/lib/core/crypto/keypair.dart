import 'package:solana/solana.dart';

class KeypairService {
  /// Create Solana keypair from mnemonic (official Solana Flutter API)
  static Future<Ed25519HDKeyPair> fromMnemonic(String mnemonic) async {
    return Ed25519HDKeyPair.fromMnemonic(mnemonic);
  }
}