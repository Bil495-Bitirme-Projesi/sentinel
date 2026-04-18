// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'alert_status.dart';

class AlertStatusMapper extends EnumMapper<AlertStatus> {
  AlertStatusMapper._();

  static AlertStatusMapper? _instance;
  static AlertStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AlertStatusMapper._());
    }
    return _instance!;
  }

  static AlertStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  AlertStatus decode(dynamic value) {
    switch (value) {
      case 'UNSEEN':
        return AlertStatus.unseen;
      case 'ACKNOWLEDGED':
        return AlertStatus.acknowledged;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(AlertStatus self) {
    switch (self) {
      case AlertStatus.unseen:
        return 'UNSEEN';
      case AlertStatus.acknowledged:
        return 'ACKNOWLEDGED';
    }
  }
}

extension AlertStatusMapperExtension on AlertStatus {
  dynamic toValue() {
    AlertStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<AlertStatus>(this);
  }
}

