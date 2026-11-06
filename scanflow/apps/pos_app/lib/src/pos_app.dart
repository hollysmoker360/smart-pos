import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pos_api.dart';
import 'pos_controller.dart';
import 'pos_screen.dart';
import 'pos_session_store.dart';

final posApiProvider = Provider<PosApi>((ref) {
  final api = HttpPosApi();
  ref.onDispose(api.close);
  return api;
});

final posSessionStoreProvider = Provider<PosSessionStore>(
  (ref) => SecurePosSessionStore(),
);

final posControllerProvider = ChangeNotifierProvider<PosController>((ref) {
  final controller = PosController(
    api: ref.watch(posApiProvider),
    sessionStore: ref.watch(posSessionStoreProvider),
  );
  unawaited(controller.restoreSession());
  return controller;
});

class ScanFlowPosApp extends ConsumerWidget {
  const ScanFlowPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(posControllerProvider);
    return MaterialApp(
      title: 'ScanFlow POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF087F5B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: switch (controller.status) {
        PosAppStatus.initializing => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        PosAppStatus.signedOut => const PosSignInScreen(),
        PosAppStatus.signedIn => const PosCheckoutScreen(),
      },
    );
  }
}
