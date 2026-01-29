import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmMnemonicPage extends ConsumerStatefulWidget {
  final String mnemonic;

  const ConfirmMnemonicPage({
    super.key,
    required this.mnemonic,
  });

  @override
  ConsumerState<ConfirmMnemonicPage> createState() =>
      _ConfirmMnemonicPageState();
}

class _ConfirmMnemonicPageState
    extends ConsumerState<ConfirmMnemonicPage> {
  late final List<String> _original;
  late final List<String> _shuffled;
  final List<String> _selected = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _original = widget.mnemonic.split(' ');
    _shuffled = List.of(_original)..shuffle();
  }

  void _tapWord(String word) {
    if (_selected.contains(word)) return;
    setState(() {
      _selected.add(word);
      _error = null;
    });
  }

  void _removeLast() {
    if (_selected.isEmpty) return;
    setState(() {
      _selected.removeLast();
    });
  }

  void _confirm() {
    if (_selected.length != _original.length) {
      setState(() => _error = 'Select all words');
      return;
    }

    final joined = _selected.join(' ');
    if (joined != widget.mnemonic) {
      setState(
        () => _error = 'Incorrect order. Try again.',
      );
      return;
    }

    /// âœ… RETURN SUCCESS KE CREATE_WALLET_PAGE
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Confirm Recovery Phrase')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tap the words in the correct order.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /// Selected words
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selected.map((w) {
                return Chip(
                  label: Text(w),
                  onDeleted: _removeLast,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            /// Word pool
            Expanded(
              child: GridView.builder(
                itemCount: _shuffled.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, i) {
                  final w = _shuffled[i];
                  final used = _selected.contains(w);
                  return ElevatedButton(
                    onPressed:
                        used ? null : () => _tapWord(w),
                    child: Text(w),
                  );
                },
              ),
            ),

            if (_error != null)
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style:
                      const TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}