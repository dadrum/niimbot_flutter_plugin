import 'package:flutter/foundation.dart';

@immutable
class ParentProperty { // "printModeName": "Thermal printing"

  const ParentProperty({
    required this.name,
    required this.density,
    required this.code,
    required this.multilingualCode,
    required this.printModeValue,
    required this.printModeName,
  });

  factory ParentProperty.fromJson(Map<String, dynamic> json) {
    return ParentProperty(
      name: json['name'],
      density: json['density'],
      code: json['code'],
      multilingualCode: json['multilingualCode'],
      printModeValue: json['printModeValue'],
      printModeName: json['printModeName'],
    );
  }

  final String name; // "name": "Thermal synthetic paper",
  final int? density; // "density": null,
  final int code; // "code": 1,
  final String multilingualCode; // "multilingualCode": "app01230",
  final String printModeValue; // "printModeValue": "1",
  final String printModeName;
}
