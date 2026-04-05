import 'package:flutter/material.dart';
/// Tek bir alert'in detay ekrani.
/// [alertId]: gosterilecek alert'in ID'si.
/// TODO: GET /alerts/{id}, POST read/ack/false-positive, video clip
class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({super.key, required this.alertId});
  final String alertId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alert #$alertId')),
      body: const Center(child: Text('Alert detail --- yapilacak')),
    );
  }
}
