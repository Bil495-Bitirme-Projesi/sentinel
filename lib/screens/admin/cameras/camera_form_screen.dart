import 'package:flutter/material.dart';
/// Kamera olusturma / duzenleme ekrani.
/// [cameraId] null ise 'yeni olustur', dolu ise 'duzenle' modudir.
/// TODO: POST /cameras ve PUT /cameras/{id} implementasyonu
class CameraFormScreen extends StatelessWidget {
  const CameraFormScreen({super.key, this.cameraId});
  final String? cameraId;
  bool get isEdit => cameraId != null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Kamera Duzenle' : 'Kamera Ekle')),
      body: const Center(child: Text('Camera form --- yapilacak')),
    );
  }
}
