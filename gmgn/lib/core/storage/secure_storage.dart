import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _seedKey = 'wallet_mnemonic';

  // ðŸ”’ HARDENED STORAGE (WAJIB UNTUK RELEASE)
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility:
          KeychainAccessibility.first_unlock,
    ),
  );

  static Future<void> saveSeed(String mnemonic) async {
    await _storage.write(
      key: _seedKey,
      value: mnemonic,
    );
  }

  static Future<String?> loadSeed() async {
    return _storage.read(key: _seedKey);
  }

  static Future<void> clearSeed() async {
    await _storage.delete(key: _seedKey);
  }
}