import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trixx_provider.dart';

class StoreAndTrolleyScreen extends ConsumerStatefulWidget {
  final VoidCallback onConnected;

  const StoreAndTrolleyScreen({super.key, required this.onConnected});

  @override
  ConsumerState<StoreAndTrolleyScreen> createState() =>
      _StoreAndTrolleyScreenState();
}

class _StoreAndTrolleyScreenState extends ConsumerState<StoreAndTrolleyScreen> {
  final _trolleyController = TextEditingController(text: 'TRL-001');
  final _customerController = TextEditingController(text: 'CUST-1001');
  final _branchController = TextEditingController(text: 'BRANCH-001');

  @override
  void dispose() {
    _trolleyController.dispose();
    _customerController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(trixxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shopping_cart_checkout, color: Color(0xFF44D895)),
            SizedBox(width: 9),
            Text('ScanFlow'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                const Icon(Icons.wifi, size: 17, color: Color(0xFF9BE5C1)),
                const SizedBox(width: 5),
                Text(
                  'Ready',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SCAN. SHOP. GO.',
                style: TextStyle(
                  color: Color(0xFF087F5B),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ready to shop?',
                style: TextStyle(
                  color: Color(0xFF17352C),
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF06382E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.shopping_cart_checkout,
                      size: 54,
                      color: Color(0xFF44D895),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Scan products as you shop.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your basket and total update with store-confirmed prices.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final success = await provider.claimTrolley(
                                trolleyCode: _trolleyController.text.trim(),
                                customerId: _customerController.text.trim(),
                                branchId: _branchController.text.trim(),
                              );
                              if (success) widget.onConnected();
                            },
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.qr_code_scanner),
                      label: Text(
                        provider.isLoading ? 'Connecting...' : 'Start scanning',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF08A66A),
                        minimumSize: const Size.fromHeight(54),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statusTile(
                          Icons.shopping_basket_outlined,
                          'Basket',
                          '0 items',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 42,
                        color: const Color(0xFFDCE7E1),
                      ),
                      Expanded(
                        child: _statusTile(
                          Icons.battery_charging_full,
                          'Trolley',
                          '98%',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 42,
                        color: const Color(0xFFDCE7E1),
                      ),
                      Expanded(
                        child: _statusTile(
                          Icons.help_outline,
                          'Help',
                          'Available',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE9E7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Color(0xFFB94A48)),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Connect a trolley',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17352C),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Enter the code displayed on your trolley if QR scanning is unavailable.',
                style: TextStyle(color: Color(0xFF72827B), fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _trolleyController,
                decoration: const InputDecoration(
                  labelText: 'Trolley code',
                  prefixIcon: Icon(Icons.qr_code_2),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final success = await provider.claimTrolley(
                          trolleyCode: _trolleyController.text.trim(),
                          customerId: _customerController.text.trim(),
                          branchId: _branchController.text.trim(),
                        );
                        if (success) widget.onConnected();
                      },
                icon: const Icon(Icons.link),
                label: const Text('Connect trolley'),
              ),
              if (provider.errorMessage != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Connection requires an available ScanFlow service.',
                    style: TextStyle(color: Color(0xFF72827B), fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusTile(IconData icon, String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF087F5B), size: 19),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Color(0xFF72827B)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17352C),
          ),
        ),
      ],
    );
  }
}
