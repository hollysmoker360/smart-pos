import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CodeScannerScreen extends StatefulWidget {
  const CodeScannerScreen({required this.title, super.key});

  final String title;

  @override
  State<CodeScannerScreen> createState() => _CodeScannerScreenState();
}

class _CodeScannerScreenState extends State<CodeScannerScreen> {
  bool _hasReturnedCode = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasReturnedCode) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value == null || value.isEmpty) continue;
      _hasReturnedCode = true;
      Navigator.of(context).pop(value);
      return;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: MobileScanner(
                  onDetect: _onDetect,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Camera unavailable. Check camera permission and try '
                        'again. You can also enter the code manually.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Hold the code inside the camera view.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
}
