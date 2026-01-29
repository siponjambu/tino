import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/market_provider.dart';

class TokenSearchBar extends ConsumerStatefulWidget {
  const TokenSearchBar({super.key});

  @override
  ConsumerState<TokenSearchBar> createState() => _TokenSearchBarState();
}

class _TokenSearchBarState extends ConsumerState<TokenSearchBar> {
  final TextEditingController controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 300), // âœ… Phantom-like debounce
      () {
        final q = value.trim();

        final notifier = ref.read(marketProvider.notifier);

        if (q.isEmpty) {
          notifier.clearSearch();
        } else {
          notifier.search(q);
        }
      },
    );
  }

  void _onClear() {
    controller.clear();
    ref.read(marketProvider.notifier).clearSearch();

    // ðŸ”¥ penting: refresh suffixIcon
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search token (mint / symbol / pair)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _onClear,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (v) {
          _onChanged(v);

          // ðŸ”¥ hanya untuk update suffixIcon
          if (mounted) {
            setState(() {});
          }
        },
        textInputAction: TextInputAction.search,
        onSubmitted: (_) {
          // âœ… Phantom-style:
          // ENTER = search saja, BUKAN buka chart
        },
      ),
    );
  }
}