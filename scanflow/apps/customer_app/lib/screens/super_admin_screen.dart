import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  Map<String, dynamic>? adminData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminOverview();
  }

  void fetchAdminOverview() async {
    try {
      final res = await ApiService.getAdminOverview();
      setState(() {
        adminData = res;
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
        title: const Text('ScanFlow Platform Admin'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: const Color(0xFF12372A),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Platform System Health', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text('Status: ${adminData?['systemStatus'] ?? 'OPERATIONAL'}',
                              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('Server Time: ${adminData?['serverTime']}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
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
                          const Text('Tenant SaaS Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.business, color: Color(0xFF12372A)),
                            title: const Text('Supermarket Tenants'),
                            subtitle: Text('${adminData?['activeTenants'] ?? 1} Active Supermarket Accounts'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.store, color: Color(0xFF12372A)),
                            title: const Text('Branch Outlets'),
                            subtitle: Text('${adminData?['activeBranches'] ?? 2} Registered Branches'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.swap_horiz, color: Color(0xFF12372A)),
                            title: const Text('Total Transactions Processed'),
                            subtitle: Text('${adminData?['totalTransactions'] ?? 0} Orders'),
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
