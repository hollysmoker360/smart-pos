import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/shopping_provider.dart';
import 'screens/store_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/basket_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/receipt_screen.dart';
import 'screens/exit_attendant_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/super_admin_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ShoppingProvider(),
      child: const TrixxApp(),
    ),
  );
}

class TrixxApp extends StatelessWidget {
  const TrixxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanFlow',
      debugShowCheckedModeBanner: false,
      theme: TrixxTheme.themeData,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('sw', 'KE'),
      ],
      initialRoute: '/store-select',
      routes: {
        '/store-select': (context) => const StoreSelectionScreen(),
        '/home': (context) => const HomeScreen(),
        '/scanner': (context) => const ScannerScreen(),
        '/basket': (context) => const BasketScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/receipt': (context) => const ReceiptScreen(),
        '/exit-attendant': (context) => const ExitAttendantScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/super-admin': (context) => const SuperAdminScreen(),
      },
    );
  }
}
