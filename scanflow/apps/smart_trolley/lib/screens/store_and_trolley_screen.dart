import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trixx_provider.dart';

class StoreAndTrolleyScreen extends StatefulWidget {
  final VoidCallback onConnected;

  const StoreAndTrolleyScreen({super.key, required this.onConnected});

  @override
  State<StoreAndTrolleyScreen> createState() => _StoreAndTrolleyScreenState();
}

class _StoreAndTrolleyScreenState extends State<StoreAndTrolleyScreen> {
  final _trolleyController = TextEditingController(text: 'TRL-001');
  final _customerController = TextEditingController(text: 'CUST-1001');
  final _branchController = TextEditingController(text: 'BRANCH-001');

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrixxProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TRIXX SmartTrolley'),
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
                    const Icon(Icons.shopping_cart, size: 64, color: Colors.teal),
                    const SizedBox(height: 12),
                    const Text(
                      'Welcome to QuickMart Kilimani',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan the QR code on your SmartTrolley or enter details below to start shopping.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
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
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(
                labelText: 'Customer ID',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _branchController,
              decoration: const InputDecoration(
                labelText: 'Branch ID',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _trolleyController,
              decoration: const InputDecoration(
                labelText: 'Trolley QR / Code',
                prefixIcon: Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      bool success = await provider.claimTrolley(
                        trolleyCode: _trolleyController.text.trim(),
                        customerId: _customerController.text.trim(),
                        branchId: _branchController.text.trim(),
                      );
                      if (success) {
                        widget.onConnected();
                      }
                    },
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Connect Trolley & Start Shopping', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
