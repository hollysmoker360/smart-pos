import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shopping_provider.dart';

class StoreSelectionScreen extends ConsumerStatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  ConsumerState<StoreSelectionScreen> createState() =>
      _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends ConsumerState<StoreSelectionScreen> {
  final _branchIdController = TextEditingController();

  @override
  void dispose() {
    _branchIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(shoppingProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_cart_checkout, color: Color(0xFF44D895)),
            SizedBox(width: 8),
            Text('ScanFlow'),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Text(
                'WELCOME TO SCANFLOW',
                style: TextStyle(
                  color: Color(0xFF087F5B),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your store',
                style: TextStyle(
                  color: Color(0xFF17352C),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan the store QR code or enter its branch ID to start a '
                'secure shopping session.',
                style: TextStyle(color: Color(0xFF72827B)),
              ),
              const SizedBox(height: 24),
              TextField(
                key: const Key('branchId'),
                controller: _branchIdController,
                textInputAction: TextInputAction.go,
                decoration: const InputDecoration(
                  labelText: 'Store QR / branch ID',
                  hintText: 'UUID from the store QR code',
                  prefixIcon: Icon(Icons.qr_code_2),
                ),
                onSubmitted: (_) => _joinStore(),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: provider.isLoading ? null : _joinStore,
                icon: provider.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.storefront),
                label:
                    Text(provider.isLoading ? 'Connecting...' : 'Join store'),
              ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: const Color(0xFFFCE9E7),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Color(0xFFB94A48)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'The store name, currency, availability and all prices are '
                'confirmed by the ScanFlow API.',
                style: TextStyle(color: Color(0xFF72827B), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinStore() async {
    final branchId = _branchIdController.text.trim();
    if (branchId.isEmpty) return;
    final joined = await ref.read(shoppingProvider).joinStore(branchId);
    if (mounted && joined) Navigator.pushReplacementNamed(context, '/home');
  }
}
