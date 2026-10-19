import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/trixx_provider.dart';
import 'screens/store_and_trolley_screen.dart';
import 'screens/live_basket_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/receipt_screen.dart';
import 'screens/staff_dashboard_screen.dart';

void main() {
  runApp(const TrixxApp());
}

class TrixxApp extends StatelessWidget {
  const TrixxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrixxProvider()),
      ],
      child: MaterialApp(
        title: 'TRIXX SmartTrolley',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MainNavigationWrapper(),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentStepIndex = 0;
  bool _isStaffMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('TRIXX SmartTrolley', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Smart Retail Platform', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: const Text('Customer App Flow'),
              selected: !_isStaffMode,
              onTap: () {
                setState(() {
                  _isStaffMode = false;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.teal),
              title: const Text('Staff & Admin Dashboard'),
              selected: _isStaffMode,
              onTap: () {
                setState(() {
                  _isStaffMode = true;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isStaffMode
          ? const StaffDashboardScreen()
          : IndexedStack(
              index: _currentStepIndex,
              children: [
                StoreAndTrolleyScreen(
                  onConnected: () {
                    setState(() {
                      _currentStepIndex = 1;
                    });
                  },
                ),
                LiveBasketScreen(
                  onProceedToCheckout: () {
                    setState(() {
                      _currentStepIndex = 2;
                    });
                  },
                ),
                CheckoutScreen(
                  onPaymentComplete: () {
                    setState(() {
                      _currentStepIndex = 3;
                    });
                  },
                ),
                ReceiptScreen(
                  onNewShoppingSession: () {
                    setState(() {
                      _currentStepIndex = 0;
                    });
                  },
                ),
              ],
            ),
    );
  }
}
