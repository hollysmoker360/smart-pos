import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_provider.dart';

class BasketScreen extends ConsumerWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(shoppingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Basket'),
      ),
      body: Column(
        children: [
          if (provider.errorMessage != null)
            Material(
              color: const Color(0xFFFCE9E7),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: Text(provider.errorMessage!)),
                    IconButton(
                      tooltip: 'Refresh basket',
                      onPressed: provider.refreshBasket,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: provider.basketItems.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE6F4ED),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.shopping_basket_outlined,
                              size: 34, color: Color(0xFF087F5B))),
                      const SizedBox(height: 14),
                      const Text('Your basket is empty',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF17352C))),
                      const SizedBox(height: 5),
                      const Text('Scan your first item to get started.',
                          style: TextStyle(color: Color(0xFF72827B))),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/scanner'),
                          icon: const Icon(Icons.center_focus_strong),
                          label: const Text('Scan an item')),
                    ]),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                          itemCount: provider.basketItems.length,
                          itemBuilder: (context, index) {
                            final item = provider.basketItems[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFE6F4ED),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Icon(
                                          Icons.inventory_2_outlined,
                                          color: Color(0xFF087F5B)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              item['productName'] ??
                                                  item['productSku'] ??
                                                  'Scanned product',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF17352C))),
                                          const SizedBox(height: 3),
                                          Text('KES ${item['unitPrice']} each',
                                              style: const TextStyle(
                                                  color: Color(0xFF72827B),
                                                  fontSize: 12)),
                                          const SizedBox(height: 3),
                                          Text(
                                              'KES ${item['totalPrice'] ?? item['lineTotal']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF087F5B))),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          color: const Color(0xFF087F5B),
                                          visualDensity: VisualDensity.compact,
                                          onPressed: provider.isLoading
                                              ? null
                                              : () {
                                                  if (item['quantity'] > 1) {
                                                    provider.updateItemQuantity(
                                                      item['id'],
                                                      item['quantity'] - 1,
                                                    );
                                                  } else {
                                                    provider
                                                        .removeItem(item['id']);
                                                  }
                                                },
                                        ),
                                        Text('${item['quantity']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15)),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          color: const Color(0xFF087F5B),
                                          visualDensity: VisualDensity.compact,
                                          onPressed: provider.isLoading
                                              ? null
                                              : () {
                                                  provider.updateItemQuantity(
                                                    item['id'],
                                                    item['quantity'] + 1,
                                                  );
                                                },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border:
                              Border(top: BorderSide(color: Color(0xFFDCE7E1))),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Estimated total',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    '${provider.currency} ${provider.basketTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF06382E))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: provider.basketItems.isEmpty
                                  ? null
                                  : () =>
                                      Navigator.pushNamed(context, '/checkout'),
                              child:
                                  const Text('Review checkout availability  →'),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
