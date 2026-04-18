import 'package:dart_mappable/dart_mappable.dart';

part 'camera.mapper.dart';

// JSON'dan gelen "ONLINE", "OFFLINE" gibi büyük harfli metinleri
// otomatik eşleştirmek için caseStyle ekliyoruz.
@MappableEnum(caseStyle: CaseStyle.upperCase)
enum StreamStatus {
  unknown,
  online,
  offline,
}

@MappableClass()
class Camera with CameraMappable {
  final int id;
  final String name;
  final String rtspUrl;
  final bool detectionEnabled; // Senin orijinal kodundaki alan (Korundu)

  // Görevden gelen yeni alanlar
  final StreamStatus streamStatus;
  final DateTime? lastHeartbeatAt;

  Camera({
    required this.id,
    required this.name,
    required this.rtspUrl,
    required this.detectionEnabled, // Korundu
    this.streamStatus = StreamStatus.unknown, // Varsayılan değer
    this.lastHeartbeatAt, // Nullable olabilir
  });
}