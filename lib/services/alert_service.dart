import 'package:dio/dio.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/models/alert_detail.dart';
import 'package:sentinel/models/alert_summary.dart';

class AlertService {
  AlertService._();
  static final AlertService instance = AlertService._();

  final Dio _cms = CmsClient.instance;

  Future<List<AlertSummary>> getAlerts({
    String? status,
    int? cameraId,
    DateTime? from,
    DateTime? to,
    String? type,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (cameraId != null) params['cameraId'] = cameraId;
    if (from != null) params['from'] = from.toUtc().toIso8601String();
    if (to != null) params['to'] = to.toUtc().toIso8601String();
    if (type != null) params['type'] = type;

    final response = await _cms.get('/alerts', queryParameters: params);
    return (response.data as List)
        .map((json) => AlertSummaryMapper.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  Future<AlertDetail> getAlertDetail(int alertId) async {
    final response = await _cms.get('/alerts/$alertId');
    return AlertDetailMapper.fromMap(response.data as Map<String, dynamic>);
  }

  Future<void> acknowledge(int alertId) async {
    await _cms.patch('/alerts/$alertId/acknowledge');
  }

  Future<String> getClipUrl(int alertId) async {
    final response = await _cms.get('/alerts/$alertId/clip-url');
    return response.data['downloadUrl'] as String;
  }
}
