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
        title: const Text('Receipt & exit pass'),
        actions: [
          IconButton(
            tooltip: 'Finish shopping',
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              provider.clearSession();
              Navigator.pushReplacementNamed(context, '/store-select');
            },
          ),
        ],
      ),
      body: receipt == null || exitPass == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_top, size: 48, color: Color(0xFFA56D13)),
                    const SizedBox(height: 12),
                    const Text('Payment confirmation pending', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF17352C))),
                    const SizedBox(height: 8),
                    const Text('An M-Pesa prompt is not proof of payment. Your receipt and exit pass will appear after the store confirms payment.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF72827B), height: 1.45)),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Return to checkout')),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    color: const Color(0xFF06382E),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF44D895), size: 52),
                          const SizedBox(height: 10),
                          const Text('Payment confirmed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                          const SizedBox(height: 5),
                          const Text('Show this pass at the exit.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: QrImageView(data: exitPass['tokenHash'] ?? exitPass['tokenCode'] ?? '', version: QrVersions.auto, size: 184),
                          ),
                          const SizedBox(height: 12),
                          Text('Pass expires ${exitPass['expiresAt'] ?? 'as shown by the store'}', style: const TextStyle(color: Color(0xFFB7EBD1), fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [Icon(Icons.receipt_long, color: Color(0xFF087F5B)), SizedBox(width: 8), Text('Digital receipt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))]),
                          const Divider(height: 24),
                          Text('Receipt ${receipt['receiptNumber'] ?? ''}'),
                          Text('Store: ${provider.branchName ?? 'ScanFlow store'}'),
                          Text('Date: ${receipt['createdAt'] ?? ''}'),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total paid', style: TextStyle(fontWeight: FontWeight.w700)), Text('KES ${receipt['totalAmount'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Color(0xFF087F5B)))]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
