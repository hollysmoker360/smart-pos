import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(shoppingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Color(0xFF18D58A)),
            const SizedBox(width: 8),
            const Text('ScanFlow',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            Container(width: 1, height: 22, color: Colors.white24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                provider.branchName ?? 'Choose a store',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            tooltip: 'Change store',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/store-select');
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('READY WHEN YOU ARE',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
              const SizedBox(height: 6),
              const Text('Shop at your own pace.',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17352C))),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF06382E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF145545)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.qr_code_scanner,
                              color: Color(0xFF44D895)),
                        ),
                        const SizedBox(width: 12),
                        const Text('Scan. Shop. Go.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text('Your phone is your checkout.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.2,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text(
                        'Scan each item as you shop. Your basket updates with store-confirmed prices.',
                        style: TextStyle(color: Colors.white70, height: 1.45)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/scanner'),
                        icon: const Icon(Icons.center_focus_strong),
                        label: const Text('Start scanning'),
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF08A66A),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pushNamed(context, '/basket'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: const Color(0xFFE6F4ED),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.shopping_basket_outlined,
                                color: Color(0xFF087F5B))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const Text('Your basket',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              Text('${provider.basketItemCount} items added',
                                  style: const TextStyle(
                                      color: Color(0xFF72827B), fontSize: 13))
                            ])),
                        Text(
                            '${provider.currency} ${provider.basketTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF17352C))),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF72827B)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined,
                      size: 18, color: Color(0xFF087F5B)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Prices confirmed by ${provider.branchName ?? 'your selected store'}',
                          style: const TextStyle(
                              color: Color(0xFF72827B), fontSize: 12))),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.shopping_basket_outlined), label: 'Basket'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Receipts'),
        ],
        onDestinationSelected: (index) {
          if (index == 1) Navigator.pushNamed(context, '/basket');
          if (index == 2) Navigator.pushNamed(context, '/receipt');
        },
      ),
    );
  }
}
