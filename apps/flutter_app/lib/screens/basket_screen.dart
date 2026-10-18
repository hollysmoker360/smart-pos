import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Basket'),
      ),
      body: provider.basketItems.isEmpty
          ? const Center(
              child: Text(
                'Your basket is empty.\nScan products to add them.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.basketItems.length,
                    itemBuilder: (context, index) {
                      final item = provider.basketItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF12372A).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shopping_bag, color: Color(0xFF12372A)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Barcode: ${item['barcode']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Unit: KES ${item['unitPrice']}'),
                                    Text('Total: KES ${item['totalPrice']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF12372A))),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      provider.updateItemQuantity(item['id'], item['quantity'] - 1);
                                    },
                                  ),
                                  Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      provider.updateItemQuantity(item['id'], item['quantity'] + 1);
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
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('KES ${provider.basketTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF12372A))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await provider.performCheckout();
                          Navigator.pushNamed(context, '/checkout');
                        },
                        child: const Text('Proceed to Checkout'),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
