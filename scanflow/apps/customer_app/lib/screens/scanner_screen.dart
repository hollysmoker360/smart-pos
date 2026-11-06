import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _addManualBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      try {
        await ref.read(shoppingProvider).scanAndAddItem(barcode);
        if (!mounted) return;
        _barcodeController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added: $barcode')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a product')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('BARCODE SCANNER',
                  style: TextStyle(
                      color: Color(0xFF087F5B),
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Line up the barcode',
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17352C))),
              const SizedBox(height: 14),
              Container(
                height: 285,
                decoration: BoxDecoration(
                    color: const Color(0xFF062B25),
                    borderRadius: BorderRadius.circular(10)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.center_focus_strong,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 48),
                        const SizedBox(height: 12),
                        const Text(
                            'Camera scanning is not connected yet.\nEnter the barcode below.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    Container(
                        width: 230,
                        height: 118,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF44D895), width: 2),
                            borderRadius: BorderRadius.circular(8))),
                    Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Row(children: [
                              Icon(Icons.circle,
                                  size: 7, color: Color(0xFF44D895)),
                              SizedBox(width: 6),
                              Text('MANUAL MODE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700))
                            ]))),
                    const Positioned(
                        bottom: 14,
                        child: Text('EAN-13  ·  UPC-A  ·  CODE 128',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Enter barcode',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF17352C))),
              const SizedBox(height: 8),
              TextField(
                controller: _barcodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Barcode number',
                    prefixIcon: Icon(Icons.qr_code_2)),
                onSubmitted: (_) => _addManualBarcode(),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                  onPressed: _addManualBarcode,
                  icon: const Icon(Icons.add),
                  label: const Text('Add to basket')),
              const SizedBox(height: 12),
              const Row(children: [
                Icon(Icons.info_outline, color: Color(0xFF72827B), size: 17),
                SizedBox(width: 7),
                Expanded(
                    child: Text(
                        'Prices and availability are confirmed by the store.',
                        style:
                            TextStyle(color: Color(0xFF72827B), fontSize: 12)))
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
