import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow_design_system/scanflow_design_system.dart';

import 'src/admin_app.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'ScanFlow Admin',
        debugShowCheckedModeBanner: false,
        theme: ScanFlowTheme.light,
        home: const AdminApp(),
      ),
    ),
  );
}
