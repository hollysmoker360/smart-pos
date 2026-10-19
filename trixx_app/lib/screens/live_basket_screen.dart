import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trixx_provider.dart';

class LiveBasketScreen extends StatefulWidget {
  final VoidCallback onProceedToCheckout;

  const LiveBasketScreen({super.key, required this.onProceedToCheckout});

  @override
  State<LiveBasketScreen> createState() => _LiveBasketScreenState();
}

class _LiveBasketScreenState extends State<LiveBasketScreen> {
  final _barcodeController = TextEditingController(text: '6001234567890');

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrixxProvider>(context);
    final basket = provider.currentBasket;
    final session = provider.currentSession;

    return Scaffold(
      appBar: AppBar(
        title: Text('Connected: ${session?.trolleyId ?? "TRL-001"}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refreshBasket(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  label: Text('Session: ${session?.sessionId ?? ""}'),
                  backgroundColor: Colors.white,
                ),
                Chip(
                  avatar: const Icon(Icons.battery_charging_full, color: Colors.teal, size: 18),
                  label: const Text('Battery: 98%'),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),

          // Scan simulation box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Simulate Barcode Scan',
                          hintText: 'e.g. 6001234567890 or 6009876543210',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final barcode = _barcodeController.text.trim();
                              if (barcode.isNotEmpty) {
                                await provider.sendScanEvent(barcode);
                              }
                            },
                      icon: const Icon(Icons.scanner),
                      label: const Text('Scan'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),

          // Basket items list
          Expanded(
            child: basket == null || basket.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Your basket is currently empty.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text('Scan items using the physical trolley scanner.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: basket.items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = basket.items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text('${item.quantity}x', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Barcode: ${item.barcode} | KES ${item.unitPrice.toStringAsFixed(2)} each'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'KES ${item.lineTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                await provider.removeItem(item.itemId);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Basket Summary & Checkout Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(color: Colors.grey)),
                    Text('KES ${(basket?.subtotal ?? 0.0).toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VAT (16%):', style: TextStyle(color: Colors.grey)),
                    Text('KES ${(basket?.taxes ?? 0.0).toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discounts:', style: TextStyle(color: Colors.grey)),
                    Text('- KES ${(basket?.totalDiscounts ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'KES ${(basket?.estimatedTotal ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: (basket == null || basket.items.isEmpty || provider.isLoading)
                        ? null
                        : () async {
                            bool success = await provider.createCheckout();
                            if (success) {
                              widget.onProceedToCheckout();
                            }
                          },
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Proceed to Checkout Snapshot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
