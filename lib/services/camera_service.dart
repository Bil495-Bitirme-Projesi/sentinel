import 'package:dio/dio.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/camera.dart';
import 'package:sentinel/models/user_camera_access.dart';

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

  // Threshold parametresi eklendi
    Future<void> createCamera(String name, String rtspUrl, double threshold) async {
      await _cms.post('/admin/cameras', data: {
        "name": name,
        "rtspUrl": rtspUrl,
        "threshold": threshold, // Backend'in beklediği zorunlu alan
      });
    }

    // Threshold parametresi eklendi
    Future<void> updateCamera(int id, String name, String rtspUrl, double threshold) async {
      await _cms.put('/admin/cameras/$id', data: {
        "name": name,
        "rtspUrl": rtspUrl,
        "threshold": threshold, // Backend'in beklediği zorunlu alan
      });
    }

  Future<void> deleteCamera(int id) async {
    await _cms.delete('/admin/cameras/$id');
  }

  // ── KULLANICI ERİŞİM (ACCESS) İŞLEMLERİ ─────────────────────────────────

  Future<List<UserCameraAccess>> getUserAccessList(int userId) async {
    final response = await _cms.get('/admin/access/$userId');
    return (response.data as List).map((json) => UserCameraAccessMapper.fromMap(json as Map<String, dynamic>)).toList();
  }

  Future<void> grantAccess(int userId, int cameraId) async {
    await _cms.post('/admin/access/grant', queryParameters: {
      'userId': userId,
      'cameraId': cameraId
    });
  }

  Future<void> revokeAccess(int userId, int cameraId) async {
    await _cms.delete('/admin/access/revoke', queryParameters: {
      'userId': userId,
      'cameraId': cameraId
    });
  }
}