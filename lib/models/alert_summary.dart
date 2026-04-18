import 'package:dart_mappable/dart_mappable.dart';
import 'package:sentinel/models/alert_status.dart';

part 'alert_summary.mapper.dart';

@MappableClass()
class AlertSummary with AlertSummaryMappable {
  final int alertId;
  final int eventId;
  final int cameraId;
  final String? cameraName;
  final DateTime timestamp;
  final String type;
  final double score;
  final String? description;
  final AlertStatus status;

  const AlertSummary({
    required this.alertId,
    required this.eventId,
    required this.cameraId,
    this.cameraName,
    required this.timestamp,
    required this.type,
    required this.score,
    this.description,
    required this.status,
  });
}
