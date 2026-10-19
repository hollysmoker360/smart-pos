import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isFlashOn = false;

  void _addManualBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      try {
        await Provider.of<ShoppingProvider>(context, listen: false).scanAndAddItem(barcode);
        _barcodeController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added: $barcode')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Barcode Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white.withOpacity(0.6), size: 64),
                      const SizedBox(height: 12),
                      const Text(
                        'Point Camera at Product Barcode\n(EAN-13, UPC-A, UPC-E)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8B04A), width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Manual Barcode Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        hintText: 'Enter EAN / UPC Barcode (e.g. 6001234567890)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _addManualBarcode,
                      child: const Text('Add to Basket'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFFE8B04A)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Duplicate Scan Warning: Scanning the same barcode twice will ask before incrementing quantity.',
                        style: TextStyle(fontSize: 13),
                      ),
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
