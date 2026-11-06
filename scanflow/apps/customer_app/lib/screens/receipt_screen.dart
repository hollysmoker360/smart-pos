import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shopping_provider.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(shoppingProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        actions: [
          IconButton(
            tooltip: 'Finish shopping',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () async {
              await ref.read(shoppingProvider).clearSession();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/store-select');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: Color(0xFF72827B),
              ),
              const SizedBox(height: 12),
              Text(
                'No paid receipts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Receipts and exit passes are available after durable order '
                'and verified payment APIs are implemented. ScanFlow will '
                'not display a payment prompt or receipt before then.',
                textAlign: TextAlign.center,
              ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
