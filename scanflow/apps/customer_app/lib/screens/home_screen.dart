import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.branchName ?? 'ScanFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/store-select');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF12372A),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Color(0xFFE8B04A), size: 56),
                    const SizedBox(height: 12),
                    const Text('Self-Checkout Barcode Scanner',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Scan items as you shop in store and pay seamlessly with M-Pesa.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/scanner'),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Start Scanning'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8B04A), foregroundColor: Colors.black),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/basket'),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_basket, size: 36, color: Color(0xFF12372A)),
                            const SizedBox(height: 8),
                            const Text('Shopping Basket', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${provider.basketItemCount} items', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/exit-attendant'),
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.security, size: 36, color: Color(0xFF12372A)),
                            SizedBox(height: 8),
                            Text('Exit Verification', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Staff Portal', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/admin-dashboard'),
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.dashboard, size: 36, color: Color(0xFF12372A)),
                            SizedBox(height: 8),
                            Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Supermarket POS', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/super-admin'),
                    child: const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 36, color: Color(0xFF12372A)),
                            SizedBox(height: 8),
                            Text('Super Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Platform SaaS', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
