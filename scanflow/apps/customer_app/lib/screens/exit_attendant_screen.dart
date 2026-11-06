import 'package:flutter/material.dart';

class ExitAttendantScreen extends StatelessWidget {
  const ExitAttendantScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Exit verification')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 52, color: Color(0xFF72827B)),
                SizedBox(height: 12),
                Text(
                  'Exit verification is not available yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'There is no backend exit-pass verification API. Do not '
                  'accept a client-generated token as proof of payment.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
}
