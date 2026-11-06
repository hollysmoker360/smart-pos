import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_provider.dart';
import '../services/api_service.dart';

class StoreSelectionScreen extends ConsumerStatefulWidget {
  const StoreSelectionScreen({super.key});

  @override
  ConsumerState<StoreSelectionScreen> createState() =>
      _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends ConsumerState<StoreSelectionScreen> {
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
        title: const Row(children: [
          Icon(Icons.shopping_cart_checkout, color: Color(0xFF44D895)),
          SizedBox(width: 8),
          Text('ScanFlow')
        ]),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : branches.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE6F4ED),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.storefront_outlined,
                              color: Color(0xFF087F5B), size: 32)),
                      const SizedBox(height: 16),
                      const Text('No stores available',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF17352C))),
                      const SizedBox(height: 6),
                      const Text(
                          'Try again in a moment or scan the store QR code to join.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF72827B))),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                          onPressed: loadBranches,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again')),
                    ]),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('WELCOME TO SCANFLOW',
                                  style: TextStyle(
                                      color: Color(0xFF087F5B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1)),
                              const SizedBox(height: 6),
                              const Text('Choose your store',
                                  style: TextStyle(
                                      color: Color(0xFF17352C),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 5),
                              Text(
                                  '${branches.length} ${branches.length == 1 ? 'location' : 'locations'} nearby',
                                  style: const TextStyle(
                                      color: Color(0xFF72827B))),
                            ]),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverList.builder(
                        itemCount: branches.length,
                        itemBuilder: (context, index) {
                          final branch = branches[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                final provider = ref.read(shoppingProvider);
                                provider.setBranch(
                                  branch['tenantId'] ??
                                      '00000000-0000-0000-0000-000000000001',
                                  branch['id'],
                                  branch['name'],
                                );
                                await provider.initSession('+254700000000');
                                if (context.mounted)
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(children: [
                                  Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFE6F4ED),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Icon(
                                          Icons.storefront_outlined,
                                          color: Color(0xFF087F5B))),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(branch['name'] ?? 'ScanFlow Store',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF17352C))),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${branch['address'] ?? 'Kenya'}  ·  ${branch['code'] ?? ''}',
                                            style: const TextStyle(
                                                color: Color(0xFF72827B),
                                                fontSize: 12)),
                                      ])),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 15, color: Color(0xFF72827B)),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
