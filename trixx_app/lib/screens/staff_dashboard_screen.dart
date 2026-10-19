import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trixx_provider.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _verifyTokenController = TextEditingController();
  String? _verificationResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      Provider.of<TrixxProvider>(context, listen: false).loadAdminData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _verifyTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrixxProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Management Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.sensor_door), text: 'Exit Verification'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Fleet Status'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Discrepancies'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Exit Station Verification Tab
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Loss Prevention / Exit Gate Terminal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _verifyTokenController,
                  decoration: const InputDecoration(
                    labelText: 'Exit Token Code',
                    hintText: 'e.g. EXIT-...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    final code = _verifyTokenController.text.trim();
                    if (code.isNotEmpty) {
                      try {
                        final res = await provider.apiService.verifyExitToken(code);
                        setState(() {
                          _verificationResult = 'Status: ${res['status']} | Valid: ${res['valid']}';
                        });
                      } catch (e) {
                        setState(() {
                          _verificationResult = 'Error: ${e.toString()}';
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Verify Exit Pass'),
                ),
                if (_verificationResult != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Text(_verificationResult!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),

          // Trolley Fleet Status Tab
          provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.trolleys.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final t = provider.trolleys[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.shopping_cart, color: Colors.white),
                      ),
                      title: Text('Trolley ${t.deviceId} (${t.serialNumber})'),
                      subtitle: Text('Status: ${t.status} | Branch: ${t.branchId}'),
                      trailing: Chip(
                        label: Text('${t.batteryLevel}%'),
                        avatar: const Icon(Icons.battery_full, size: 16),
                      ),
                    );
                  },
                ),

          // Loss Prevention Discrepancies Tab
          provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.discrepancies.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final d = provider.discrepancies[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.report_problem, color: Colors.amber, size: 32),
                        title: Text('${d.type} - Session: ${d.sessionId}'),
                        subtitle: Text(d.description),
                        trailing: Chip(
                          label: Text(d.status),
                          backgroundColor: Colors.amber.shade100,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
