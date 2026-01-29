import 'package:solana/solana.dart';

final rpcProvider = SolanaClient( rpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'), websocketUrl: Uri.parse('wss://api.mainnet-beta.solana.com'), );