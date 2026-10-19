import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';
import '../services/api_service.dart';

class StoreSelectionScreen extends StatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  List<dynamic> branches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBranches();
  }

  Future<void> loadBranches() async {
    try {
      final list = await ApiService.getBranches();
      setState(() {
        branches = list;
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
        title: const Text('TRIXX SmartPOS - Select Supermarket'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : branches.isEmpty
              ? const Center(child: Text('No supermarket branches available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.store, color: Color(0xFF12372A), size: 36),
                        title: Text(branch['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${branch['address'] ?? 'Kenya Branch'} • Code: ${branch['code']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          final provider = Provider.of<ShoppingProvider>(context, listen: false);
                          provider.setBranch(
                            branch['tenantId'] ?? '00000000-0000-0000-0000-000000000001',
                            branch['id'],
                            branch['name'],
                          );
                          await provider.initSession('+254700000000');
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
