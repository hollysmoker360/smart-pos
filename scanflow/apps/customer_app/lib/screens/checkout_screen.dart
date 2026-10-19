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
        title: const Text('Checkout & Payment'),
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
                          const Text('Order Snapshot Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const Divider(),
                          Text('Order No: ${order['orderNumber']}'),
                          Text('Status: ${order['status']}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Payable:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('KES ${order['totalAmount']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF12372A))),
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
                              Icon(Icons.phone_android, color: Color(0xFF16A34A)),
                              SizedBox(width: 8),
                              Text('Safaricom M-Pesa Express', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'M-Pesa Phone Number',
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
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                                  child: const Text('Pay with M-Pesa'),
                                ),
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
