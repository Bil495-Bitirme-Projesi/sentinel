import 'package:dart_mappable/dart_mappable.dart';

part 'camera.mapper.dart';

@MappableClass()
class Camera with CameraMappable {
  final int id;
  final String name;
  final String rtspUrl;
  final bool detectionEnabled;
  final double threshold;

  Camera({
    required this.id,
    required this.name,
    required this.rtspUrl,
    required this.detectionEnabled,
    required this.threshold,
  });
}