import 'package:flutter/foundation.dart';

@immutable
class ChildProperty { // "blindZone": "0.5|1.5|0.5|0.5"

  const ChildProperty({
    required this.name,
    required this.code,
    required this.multilingualCode,
    required this.blindZone,
  });

  factory ChildProperty.fromJson(Map<String, dynamic> json) {
    return ChildProperty(
      name: json['name'],
      code: json['code'],
      multilingualCode: json['multilingualCode'],
      blindZone: json['blindZone'],
    );
  }

  final String name; // "name": "Gap paper",
  final int code; // "code": 1,
  final String multilingualCode; // "multilingualCode": "app00280",
  final String blindZone;
}
