import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;

class MnemonicService {
  /// Generate new mnemonic (BIP39)
  static String generate() => bip39.generateMnemonic();

  /// Validate mnemonic phrase
  static bool validate(String m) => bip39.validateMnemonic(m);

  /// Convert mnemonic to seed bytes (REQUIRED for Solana keypair)
  static Uint8List toSeed(String mnemonic) {
    return bip39.mnemonicToSeed(mnemonic);
  }
}