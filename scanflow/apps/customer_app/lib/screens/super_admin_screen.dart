import 'package:flutter/material.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ScanFlow Platform Admin')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings_outlined,
                    size: 52, color: Color(0xFF72827B)),
                SizedBox(height: 12),
                Text(
                  'Platform administration is separate',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Use the authenticated ScanFlow Admin web app. System '
                  'health and tenant metrics are not served by a platform '
                  'overview API, so no estimates are shown here.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
