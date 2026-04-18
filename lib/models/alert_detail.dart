import 'package:dart_mappable/dart_mappable.dart';
import 'package:sentinel/models/alert_status.dart';

part 'alert_detail.mapper.dart';

@MappableClass()
class AlertDetail with AlertDetailMappable {
  final int id;
  final int eventId;
  final int cameraId;
  final String? cameraName;
  final DateTime timestamp;
  final double score;
  final String type;
  final String? description;
  final String? clipObjectKey;
  final AlertStatus status;

  const AlertDetail({
    required this.id,
    required this.eventId,
    required this.cameraId,
    this.cameraName,
    required this.timestamp,
    required this.score,
    required this.type,
    this.description,
    this.clipObjectKey,
    required this.status,
  });
}
