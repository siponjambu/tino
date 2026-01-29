import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/dex_pair.dart';
import '../data/services/dexscreener_service.dart';

final marketProvider =
    StateNotifierProvider<MarketNotifier, MarketState>(
  (ref) => MarketNotifier(),
);

/* ================= STATE ================= */

class MarketState {
  final List<DexPair> tokens;
  final bool loading;
  final String? error;
  final DateTime? lastUpdated;

  const MarketState({
    this.tokens = const [],
    this.loading = false,
    this.error,
    this.lastUpdated,
  });

  MarketState copyWith({
    List<DexPair>? tokens,
    bool? loading,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return MarketState(
      tokens: tokens ?? this.tokens,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/* ================= NOTIFIER ================= */

class MarketNotifier extends StateNotifier<MarketState> {
  Timer? _timer;
  bool _isFetching = false;
  String? _activeQuery;

  MarketNotifier() : super(const MarketState()) {
    _startAutoRefresh();
  }

  /* ================= AUTO REFRESH ================= */

  void _startAutoRefresh() {
    fetch(initial: true);

    _timer = Timer.periodic(
      const Duration(seconds: 5), // ðŸ”’ lebih aman dari rate limit
      (_) {
        if (_isFetching) return;

        if (_activeQuery == null) {
          fetch(silent: true);
        } else {
          search(_activeQuery!, silent: true);
        }
      },
    );
  }

  /* ================= FETCH TRENDING ================= */

  Future<void> fetch({
    bool initial = false,
    bool silent = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!silent) {
      state = state.copyWith(
        loading: true,
        clearError: true,
      );
    }

    try {
      final data = await DexscreenerService.fetchTrendingSolana();

      state = state.copyWith(
        tokens: data,
        loading: false,
        clearError: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (!silent) {
        state = state.copyWith(
          loading: false,
          error: e.toString(),
        );
      }
    } finally {
      _isFetching = false;
    }
  }

  /* ================= SEARCH ================= */

  Future<void> search(
    String q, {
    bool silent = false,
  }) async {
    final query = q.trim();
    _activeQuery = query.isEmpty ? null : query;

    if (_activeQuery == null) {
      await fetch(silent: silent);
      return;
    }

    if (_isFetching) return;
    _isFetching = true;

    if (!silent) {
      state = state.copyWith(
        loading: true,
        clearError: true,
      );
    }

    try {
      List<DexPair> result = [];

      /// 1ï¸âƒ£ Mint search
      if (query.length >= 32 && query.length <= 44) {
        result = await DexscreenerService.searchByMint(query);
      }

      /// 2ï¸âƒ£ Symbol / pair
      if (result.isEmpty) {
        result = await DexscreenerService.search(query);
      }

      /// 3ï¸âƒ£ Phantom-like fallback
      if (result.isEmpty) {
        result =
            await DexscreenerService.searchTokenLikePhantom(query);
      }

      state = state.copyWith(
        tokens: result,
        loading: false,
        clearError: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (!silent) {
        state = state.copyWith(
          loading: false,
          error: e.toString(),
        );
      }
    } finally {
      _isFetching = false;
    }
  }

  /* ================= CLEAR SEARCH ================= */

  void clearSearch() {
    _activeQuery = null;
    fetch(silent: true);
  }

  /* ================= DISPOSE ================= */

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}