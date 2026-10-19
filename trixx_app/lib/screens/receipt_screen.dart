import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/trixx_provider.dart';

class ReceiptScreen extends StatefulWidget {
  final VoidCallback onNewShoppingSession;

  const ReceiptScreen({super.key, required this.onNewShoppingSession});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _isRedeemed = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrixxProvider>(context);
    final receipt = provider.currentReceipt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Receipt & Exit Pass'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: receipt == null
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
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
                          const Icon(Icons.receipt_long, size: 56, color: Colors.teal),
                          const SizedBox(height: 8),
                          Text(receipt.branchName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Receipt #${receipt.receiptNumber}', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('Date: ${receipt.issueTimestamp}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const Divider(height: 24),
                          ...receipt.items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('${item.quantity}x ${item.productName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ),
                                    Text('KES ${item.lineTotal.toStringAsFixed(2)}'),
                                  ],
                                ),
                              )),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Paid:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('KES ${receipt.totalPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exit Pass QR Box
                  Card(
                    color: _isRedeemed ? Colors.grey.shade200 : Colors.teal.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: _isRedeemed ? Colors.grey : Colors.teal, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            _isRedeemed ? 'EXIT PASS REDEEMED' : 'SINGLE-USE EXIT PASS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _isRedeemed ? Colors.grey.shade700 : Colors.teal.shade900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!_isRedeemed) ...[
                            QrImageView(
                              data: receipt.exitTokenCode,
                              version: QrVersions.auto,
                              size: 180.0,
                            ),
                            const SizedBox(height: 8),
                            Text('Token: ${receipt.exitTokenCode}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            const Text('Scan this QR code at the exit station gate to complete your trip.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ] else ...[
                            const Icon(Icons.verified, size: 64, color: Colors.green),
                            const SizedBox(height: 8),
                            const Text('Validated & Passed Exit Gate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRedeemed ? Colors.grey : Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _isRedeemed || provider.isLoading
                                ? null
                                : () async {
                                    bool ok = await provider.redeemExitToken(receipt.exitTokenCode);
                                    if (ok) {
                                      setState(() {
                                        _isRedeemed = true;
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.sensor_door),
                            label: const Text('Simulate Exit Station Gate Scan'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.teal),
                    ),
                    onPressed: widget.onNewShoppingSession,
                    icon: const Icon(Icons.shopping_cart, color: Colors.teal),
                    label: const Text('Start New Shopping Session', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }
}
