import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Business dashboard')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.dashboard_outlined,
                    size: 52, color: Color(0xFF72827B)),
                SizedBox(height: 12),
                Text(
                  'Use ScanFlow Business',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text(
                  'Business dashboards and branch management are available '
                  'in the authenticated ScanFlow Business app. Sales, '
                  'inventory and payment reports are not yet exposed by the API.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
