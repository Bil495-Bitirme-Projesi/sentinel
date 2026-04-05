import 'package:flutter/material.dart';
/// Gecmis alert gecmisi (READ / ACK / FALSE_POSITIVE).
/// TODO: GET /alerts?from=&to=&status= implementasyonu
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gecmis')),
      body: const Center(child: Text('History --- yapilacak')),
    );
  }
}
