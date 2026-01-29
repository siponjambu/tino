import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/storage/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env WAJIB (production)
  await dotenv.load(fileName: ".env");

  // ðŸ” CEK WALLET SEBELUM APP JALAN
  final seed = await SecureStorage.loadSeed();
  final bool hasWallet = seed != null && seed.isNotEmpty;

  runApp(
    ProviderScope(
      child: App(
        hasWallet: hasWallet,
      ),
    ),
  );
}