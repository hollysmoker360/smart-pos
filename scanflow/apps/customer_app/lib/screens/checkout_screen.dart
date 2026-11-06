import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shopping_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(shoppingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 52,
                  color: Color(0xFF087F5B),
                ),
                const SizedBox(height: 12),
                Text(
                  'Payment is not available yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'ScanFlow has not connected a payment provider or durable '
                  'order API. No payment has been requested or taken. Your '
                  'server-calculated basket is still available.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Basket total: ${provider.currency} '
                  '${provider.basketTotal.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Return to basket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
