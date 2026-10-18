import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/shopping_provider.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppingProvider>(context);
    final receipt = provider.currentReceipt;
    final exitPass = provider.currentExitToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Receipt & Exit Pass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () {
              provider.clearSession();
              Navigator.pushReplacementNamed(context, '/store-select');
            },
          )
        ],
      ),
      body: receipt == null || exitPass == null
          ? const Center(child: Text('Receipt or Exit Pass not found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    color: const Color(0xFF12372A),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.verified, color: Color(0xFFE8B04A), size: 48),
                          const SizedBox(height: 8),
                          const Text('Payment Verified & Order Released',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.white,
                            child: QrImageView(
                              data: exitPass['tokenHash'],
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Exit Pass Code: ${exitPass['tokenHash']}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Expires: ${exitPass['expiresAt']}',
                              style: const TextStyle(color: Color(0xFFE8B04A), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Present this QR code to the exit attendant scanner.',
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Official Digital Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Icon(Icons.receipt_long, color: Color(0xFF12372A)),
                            ],
                          ),
                          const Divider(),
                          Text('Receipt No: ${receipt['receiptNumber']}'),
                          Text('Store: ${provider.branchName ?? 'Supermarket Branch'}'),
                          Text('Date: ${receipt['createdAt']}'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('KES ${receipt['totalAmount']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF12372A))),
                            ],
                          )
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
