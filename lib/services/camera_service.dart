import 'package:dio/dio.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/camera.dart';

class CameraService {
  CameraService._();
  static final CameraService instance = CameraService._();

  final Dio _cms = CmsClient.instance;

  // ── KAMERA CRUD İŞLEMLERİ ──────────────────────────────────────────────

  Future<List<Camera>> getAllCameras() async {
    final response = await _cms.get('/admin/cameras');
    return (response.data as List).map((json) => CameraMapper.fromMap(json as Map<String, dynamic>)).toList();
  }

  Future<Camera> getCameraById(int id) async {
    final response = await _cms.get('/admin/cameras/$id');
    return CameraMapper.fromMap(response.data as Map<String, dynamic>);
  }

  Future<void> createCamera(String name, String rtspUrl) async {
    await _cms.post('/admin/cameras', data: {
      "name": name,
      "rtspUrl": rtspUrl,
    });
  }

  Future<void> updateCamera(int id, String name, String rtspUrl) async {
    await _cms.put('/admin/cameras/$id', data: {
      "name": name,
      "rtspUrl": rtspUrl,
    });
  }

  Future<void> deleteCamera(int id) async {
    await _cms.delete('/admin/cameras/$id');
  }
}