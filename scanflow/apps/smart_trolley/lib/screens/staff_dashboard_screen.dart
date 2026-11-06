import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trixx_provider.dart';
import '../theme.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() => ref.read(trixxProvider).loadAdminData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(trixxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Management Dashboard'),
        backgroundColor: TrolleyTheme.forest,
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
          const _UnavailablePanel(
            message:
                'Exit-token verification is unavailable because the '
                'backend does not provide an exit-verification API yet.',
          ),
          _UnavailablePanel(
            message:
                provider.errorMessage ??
                'Fleet status is unavailable because the backend does not '
                    'provide device-management APIs yet.',
          ),
          _UnavailablePanel(
            message:
                provider.errorMessage ??
                'Discrepancy reporting is unavailable because the backend '
                    'does not provide reporting APIs yet.',
          ),
        ],
      ),
    );
  }
}

class _UnavailablePanel extends StatelessWidget {
  const _UnavailablePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}
