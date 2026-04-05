import 'package:flutter/material.dart';
/// Okunmamis / aktif alertlerin listesi.
/// TODO: GET /alerts?status=UNREAD implementasyonu
class AlertsListScreen extends StatelessWidget {
  const AlertsListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertler')),
      body: const Center(child: Text('Alerts list --- yapilacak')),
    );
  }
}
