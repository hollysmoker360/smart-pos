import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? salesData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSales();
  }

  void fetchSales() async {
    try {
      final data = await ApiService.getSalesReport();
      setState(() {
        salesData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supermarket POS Dashboard'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Real-Time Retail Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: const Color(0xFF12372A),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Gross Sales', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 8),
                                Text('KES ${salesData?['grossSales'] ?? '0.00'}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: const Color(0xFFE8B04A),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Completed Orders', style: TextStyle(color: Colors.black87)),
                                const SizedBox(height: 8),
                                Text('${salesData?['transactionCount'] ?? '0'}',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Management Modules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.inventory, color: Color(0xFF12372A)),
                            title: const Text('Inventory & Stock Ledger'),
                            subtitle: const Text('Track on-hand, reserved, available balances'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.receipt_long, color: Color(0xFF12372A)),
                            title: const Text('M-Pesa Payment Reconciliation'),
                            subtitle: const Text('Reconcile Daraja transactions & refunds'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.people, color: Color(0xFF12372A)),
                            title: const Text('Staff Roles & Permissions'),
                            subtitle: const Text('Manage cashiers and exit attendants'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {},
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
