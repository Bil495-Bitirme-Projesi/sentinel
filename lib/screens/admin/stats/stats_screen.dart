import 'package:flutter/material.dart';
/// Istatistik / sistem ekrani.
/// TODO: analytics endpoint'leri implementasyonu
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Istatistik')),
      body: const Center(child: Text('Stats --- yapilacak')),
    );
  }
}
