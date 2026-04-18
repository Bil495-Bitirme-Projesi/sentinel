import 'package:dart_mappable/dart_mappable.dart';

part 'alert_status.mapper.dart';

@MappableEnum()
enum AlertStatus {
  @MappableValue('UNSEEN')
  unseen,

  @MappableValue('ACKNOWLEDGED')
  acknowledged,
}
