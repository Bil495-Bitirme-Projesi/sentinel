import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/services/camera_service.dart';
import 'package:sentinel/core/navigation/app_router.dart';

class CameraFormScreen extends StatefulWidget {
  final String? cameraId;
  const CameraFormScreen({super.key, this.cameraId});

  @override
  State<CameraFormScreen> createState() => _CameraFormScreenState();
}

class _CameraFormScreenState extends State<CameraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rtspUrlController = TextEditingController();
  final _thresholdController = TextEditingController(text: '80'); // Varsayılan değer 80

  bool _isLoading = false;
  int? _parsedId;

  @override
  void initState() {
    super.initState();
    if (widget.cameraId != null) {
      _parsedId = int.tryParse(widget.cameraId!);
      if (_parsedId != null) _loadCameraData();
    }
  }

  Future<void> _loadCameraData() async {
    setState(() => _isLoading = true);
    try {
      final cam = await CameraService.instance.getCameraById(_parsedId!);
      _nameController.text = cam.name;
      _rtspUrlController.text = cam.rtspUrl;
      // Eğer modelinizde threshold varsa onu da buraya set edebilirsiniz, yoksa 80 kalır.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamera bilgileri alınamadı: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newName = _nameController.text.trim();
    final newUrl = _rtspUrlController.text.trim();
    final thresholdVal = double.tryParse(_thresholdController.text.trim()) ?? 80.0;

    try {
      // --- FRONTEND ÇAKIŞMA KONTROLÜ BAŞLANGICI ---
      // Önce mevcut kameraları çekip manuel kontrol yapıyoruz
      final existingCameras = await CameraService.instance.getAllCameras();

      final isDuplicate = existingCameras.any((cam) =>
        (cam.name.toLowerCase() == newName.toLowerCase() ||
         cam.rtspUrl.toLowerCase() == newUrl.toLowerCase()) &&
        cam.id != _parsedId // Eğer düzenleme (edit) modundaysak, kameranın kendi eski adıyla çakışmasını hata sayma
      );

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Bu kamera adı veya RTSP URL zaten kayıtlı!', style: TextStyle(fontWeight: FontWeight.w500))),
                ],
              ),
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: Duration(seconds: 4),
            )
          );
        }
        setState(() => _isLoading = false);
        return; // İŞLEMİ BURADA DURDUR (Backend'e gitme)
      }
      // --- FRONTEND ÇAKIŞMA KONTROLÜ BİTİŞİ ---

      if (_parsedId == null) {
        // Yeni Kamera Oluştur
        await CameraService.instance.createCamera(newName, newUrl, thresholdVal);
      } else {
        // Mevcut Kamerayı Güncelle
        await CameraService.instance.updateCamera(_parsedId!, newName, newUrl, thresholdVal);
      }
      if (mounted) context.go(AppRoutes.adminCameras);

    } catch (e) {
      String errorMessage = 'İşlem başarısız oldu.';

      if (e is DioException && e.response != null) {
        errorMessage = 'Sunucu Hatası: ${e.response?.data}';
      } else {
        errorMessage = 'Bağlantı Hatası: $e';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rtspUrlController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _parsedId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Kamerayı Düzenle' : 'Yeni Kamera')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Kamera Adı (Örn: Giriş Kapısı)',
                      prefixIcon: Icon(Icons.videocam),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Kamera adı gerekli' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _rtspUrlController,
                    decoration: const InputDecoration(
                      labelText: 'RTSP URL (Örn: rtsp://192.168.1.10/stream)',
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'URL gerekli';
                      final cleanUrl = val.trim().toLowerCase();
                      if (!cleanUrl.startsWith('rtsp://') && !cleanUrl.startsWith('http')) {
                        return 'Geçerli bir URL giriniz (rtsp:// veya http ile başlamalı)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _thresholdController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Algılama Hassasiyeti (Threshold)',
                      prefixIcon: Icon(Icons.tune),
                      suffixText: '%',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Hassasiyet değeri gerekli';
                      if (double.tryParse(val) == null) return 'Lütfen geçerli bir sayı girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                      isEditing ? 'Değişiklikleri Kaydet' : 'Kamerayı Ekle',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}