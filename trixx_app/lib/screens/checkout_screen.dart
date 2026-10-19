import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trixx_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback onPaymentComplete;

  const CheckoutScreen({super.key, required this.onPaymentComplete});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController(text: '254712345678');
  Timer? _poller;

  @override
  void dispose() {
    _poller?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final provider = Provider.of<TrixxProvider>(context, listen: false);
      await provider.pollPaymentStatus();
      if (provider.paymentStatus?.status == 'PAID') {
        timer.cancel();
        widget.onPaymentComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrixxProvider>(context);
    final checkout = provider.currentCheckout;
    final payment = provider.paymentStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Snapshot'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.lock_clock, size: 56, color: Colors.teal),
                    const SizedBox(height: 8),
                    const Text('Authoritative Checkout Snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Order ID: ${checkout?.orderId ?? ""}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Final Confirmed Total:', style: TextStyle(fontSize: 16)),
                        Text(
                          'KES ${(checkout?.totalAmount ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (provider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            if (payment == null) ...[
              const Text('Pay via Safaricom M-Pesa STK Push', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'M-Pesa Phone Number',
                  hintText: '2547XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        bool success = await provider.initiateMpesaPayment(_phoneController.text.trim());
                        if (success) {
                          _startPolling();
                        }
                      },
                icon: const Icon(Icons.payment),
                label: const Text('Initiate M-Pesa STK Push', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              Card(
                color: Colors.teal.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      if (payment.status == 'PAID')
                        const Icon(Icons.check_circle, size: 64, color: Colors.green)
                      else
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 4),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        payment.status == 'PAID' ? 'Payment Verified & Confirmed!' : 'Awaiting M-Pesa PIN Authorization...',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('Status: ${payment.status}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (payment.providerReference != null) ...[
                        const SizedBox(height: 4),
                        Text('Ref: ${payment.providerReference}', style: const TextStyle(color: Colors.grey)),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        onPressed: () => provider.pollPaymentStatus(),
                        child: const Text('Refresh Status Now'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
