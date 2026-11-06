import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '254700000000');
  bool _isProcessing = false;

  void _initiateMpesaPayment() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = Provider.of<ShoppingProvider>(context, listen: false);
      await provider.payWithMpesa(phone);
      setState(() {
        _isProcessing = false;
      });
      Navigator.pushReplacementNamed(context, '/receipt');
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppingProvider>(context);
    final order = provider.currentOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: order == null
          ? const Center(child: Text('No order snapshot found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF17352C))),
                          const Divider(),
                          Text('Order ${order['orderNumber'] ?? order['id'] ?? ''}', style: const TextStyle(color: Color(0xFF72827B), fontSize: 12)),
                          const SizedBox(height: 8),
                          const Row(children: [Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF087F5B)), SizedBox(width: 6), Text('Final total confirmed by store', style: TextStyle(color: Color(0xFF087F5B), fontSize: 12, fontWeight: FontWeight.w600))]),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total to pay', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              Text('KES ${order['totalAmount']}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Color(0xFF06382E))),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.phone_android, color: Color(0xFF087F5B)),
                              SizedBox(width: 8),
                              Text('M-Pesa Express', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF17352C))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: 'e.g. 254700000000',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _isProcessing
                              ? const Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 8),
                                      Text('Sending M-Pesa STK Push prompt to phone...'),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _initiateMpesaPayment,
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF08A66A)),
                                    child: const Text('Pay securely with M-Pesa'),
                                ),
                                  const SizedBox(height: 12),
                                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_outline, size: 14, color: Color(0xFF72827B)), SizedBox(width: 5), Text('Payment confirmation may take a few moments', style: TextStyle(color: Color(0xFF72827B), fontSize: 11))]),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
