import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanflow_design_system/scanflow_design_system.dart';

import '../data/business_api.dart';
import '../data/session_store.dart';
import '../state/business_app_controller.dart';
import 'auth_screen.dart';
import 'business_dashboard_screen.dart';

final businessApiProvider = Provider<BusinessApi>((ref) {
  final api = HttpBusinessApi();
  ref.onDispose(api.close);
  return api;
});

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SecureSessionStore(),
);

final businessAppControllerProvider =
    ChangeNotifierProvider<BusinessAppController>((ref) {
  final controller = BusinessAppController(
    api: ref.watch(businessApiProvider),
    sessionStore: ref.watch(sessionStoreProvider),
  );
  unawaited(controller.restoreSession());
  return controller;
});

class ScanFlowBusinessApp extends ConsumerWidget {
  const ScanFlowBusinessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(businessAppControllerProvider);
    return MaterialApp(
      title: 'ScanFlow Business',
      debugShowCheckedModeBanner: false,
      theme: ScanFlowTheme.light,
      home: switch (controller.status) {
        BusinessAppStatus.initializing => const _StartupScreen(),
        BusinessAppStatus.signedOut => const AuthScreen(),
        BusinessAppStatus.signedIn => const BusinessDashboardScreen(),
      },
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
}
