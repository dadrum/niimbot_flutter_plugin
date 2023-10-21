import 'package:flutter/foundation.dart';

@immutable
class BtDeviceInfo {

  const BtDeviceInfo({
    required this.bondState,
    required this.address,
    required this.deviceInfo,
    required this.name,
    required this.uuids,
    required this.type,
  });

  final dynamic bondState;
  final String? address;
  final String? deviceInfo;
  final String? name;
  final String? uuids;
  final int? type;
}
