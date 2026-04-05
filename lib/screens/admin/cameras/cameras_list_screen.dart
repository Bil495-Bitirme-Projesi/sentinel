import 'package:flutter/material.dart';
/// Tum kameralarin listesi.
/// TODO: GET /cameras implementasyonu
class CamerasListScreen extends StatelessWidget {
  const CamerasListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kameralar')),
      body: const Center(child: Text('Cameras list --- yapilacak')),
    );
  }
}
