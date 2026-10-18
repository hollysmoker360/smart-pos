import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ExitAttendantScreen extends StatefulWidget {
  const ExitAttendantScreen({super.key});

  @override
  State<ExitAttendantScreen> createState() => _ExitAttendantScreenState();
}

class _ExitAttendantScreenState extends State<ExitAttendantScreen> {
  final TextEditingController _tokenController = TextEditingController();
  Map<String, dynamic>? _verificationResult;
  bool _isLoading = false;
  String? _errorMessage;
  bool _inspectionPerformed = false;

  void _verifyToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _verificationResult = null;
    });

    try {
      final res = await ApiService.verifyExitToken(token);
      setState(() {
        _verificationResult = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _completeExitPass() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    try {
      await ApiService.completeExit(token, _inspectionPerformed, 'Inspection verified by attendant');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exit Approved Successfully!'), backgroundColor: Colors.green),
      );
      setState(() {
        _verificationResult = null;
        _tokenController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exit Completion Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exit Attendant Pass Verification'),
      ),
      body: SingleChildScrollView(
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
                    const Text('Scan Customer Exit Pass QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'Exit Pass Token Hash',
                        hintText: 'Enter or scan token (e.g. EXIT-xxx)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.qr_code_scanner),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _verifyToken,
                      child: const Text('Verify Pass Online'),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            if (_verificationResult != null) ...[
              Card(
                color: (_verificationResult!['valid'] as bool) ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            (_verificationResult!['valid'] as bool) ? Icons.check_circle : Icons.cancel,
                            color: (_verificationResult!['valid'] as bool) ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (_verificationResult!['valid'] as bool) ? 'VALID EXIT PASS' : 'INVALID / EXPIRED EXIT PASS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: (_verificationResult!['valid'] as bool) ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text('Order No: ${_verificationResult!['orderNumber']}'),
                      Text('Total Paid: KES ${_verificationResult!['totalAmount']}'),
                      Text('Status: ${_verificationResult!['status']}'),
                      const SizedBox(height: 12),
                      if (_verificationResult!['inspectionRequired'] == true)
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.amber.shade100,
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(child: Text('Random Risk-Based Inspection Triggered for this basket!')),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Random Basket Item Inspection Performed'),
                        value: _inspectionPerformed,
                        onChanged: (val) {
                          setState(() {
                            _inspectionPerformed = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_verificationResult!['valid'] as bool)
                        ElevatedButton(
                          onPressed: _completeExitPass,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                          child: const Text('Approve Exit & Record Pass'),
                        )
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
