import 'package:flutter/foundation.dart';

import 'device_module_consumable.dart';

@immutable
class DeviceModule {
  //// "wifiNotSupportVersions": []

  const DeviceModule({
    required this.id,
    required this.seriesId,
    required this.seriesName,
    required this.codes,
    required this.name,
    required this.status,
    required this.interfaceType,
    required this.interfaceName,
    required this.printDirection,
    required this.defaultWidth,
    required this.defaultHeight,
    required this.printMethodCode,
    required this.printMethodName,
    required this.securityAction,
    required this.solubilitySetType,
    required this.modelName,
    required this.consumables,
    required this.paperType,
    required this.thumb,
    required this.displayBootPage,
    required this.maxPrintHeight,
    required this.maxPrintWidth,
    required this.isSupportCalibration,
    required this.isSupportWifi,
    required this.paccuracyName,
    required this.paccuracy,
    required this.rfidNotSupportVersions,
    required this.rfidType,
    required this.solubilitySetDefault,
    required this.solubilitySetEnd,
    required this.solubilitySetStart,
    required this.widthSetStart,
    required this.widthSetEnd,
    required this.wifiNotSupportVersions,
  });

  factory DeviceModule.fromJson(Map<String, dynamic> json) {
    return DeviceModule(
      id: json['id'],
      seriesId: json['seriesId'],
      seriesName: json['seriesName'],
      codes: List<int>.from(json['codes']),
      name: json['name'],
      status: json['status'],
      interfaceType: json['interfaceType'],
      interfaceName: json['interfaceName'],
      printDirection: json['printDirection'],
      defaultWidth: json['defaultWidth'],
      defaultHeight: json['defaultHeigth'],
      printMethodCode: json['printMethodCode'],
      printMethodName: json['printMethodName'],
      securityAction: json['securityAction'],
      solubilitySetType: json['solubilitySetType'],
      modelName: json['modelName'],
      consumables: (json['consumables'] as List<dynamic>)
          .map((consumableJson) => DeviceModuleConsumable.fromJson(
              consumableJson as Map<String, dynamic>))
          .toList(),
      paperType: json['paperType'],
      thumb: json['thumb'],
      displayBootPage: json['displayBootPage'],
      maxPrintHeight: json['maxPrintHeight'],
      maxPrintWidth: json['maxPrintWidth'],
      isSupportCalibration: json['isSupportCalibration'],
      isSupportWifi: json['isSupportWifi'],
      paccuracyName: json['paccuracyName'],
      paccuracy: json['paccuracy'],
      rfidNotSupportVersions: List<String>.from(json['rfidNotSupportVersions']),
      rfidType: json['rfidType'],
      solubilitySetDefault: json['solubilitySetDefault'],
      solubilitySetEnd: json['solubilitySetEnd'],
      solubilitySetStart: json['solubilitySetStart'],
      widthSetStart: json['widthSetStart'],
      widthSetEnd: json['widthSetEnd'],
      wifiNotSupportVersions:
          List<Object?>.from(json['wifiNotSupportVersions']),
    );
  }

  final String id; // "id": "10017",
  final String seriesId; //"seriesId": "15",
  final String seriesName; //"seriesName": "B203",
  final Iterable<int> codes; //"codes": [2818],
  final String name; //"name": "A203",
  final int status; //"status": 0,
  final int interfaceType; //"interfaceType": 1,
  final String interfaceName; //"interfaceName": "Jingchen-Full Range",
  final int printDirection; //"printDirection": 0,
  final int defaultWidth; //"defaultWidth": 50,
  final int defaultHeight; //"defaultHeigth": 30,
  final int printMethodCode; //"printMethodCode": 2,
  final String printMethodName; //"printMethodName": "Centered",
  final int securityAction; //"securityAction": 1,
  final int solubilitySetType; //"solubilitySetType": 1,
  final String modelName; //"modelName": "Thermal printer",
  final Iterable<DeviceModuleConsumable> consumables; //"consumables": []
  final String paperType; //"paperType": "1,2,5",
  final Object? thumb; //"thumb": null,
  final int displayBootPage; //"displayBootPage": 1,
  final int maxPrintHeight; //"maxPrintHeight": 200,
  final int maxPrintWidth; //"maxPrintWidth": 50,
  final bool isSupportCalibration; //"isSupportCalibration": true,
  final bool isSupportWifi; //"isSupportWifi": false,
  final String paccuracyName; //"paccuracyName": "203",
  final int paccuracy; //: 8,
  final Iterable<String>
      rfidNotSupportVersions; //"rfidNotSupportVersions": ["1.01", "1.02",],
  final int rfidType; //"rfidType": 1,
  final int solubilitySetDefault; //"solubilitySetDefault": 3,
  final int solubilitySetEnd; //"solubilitySetEnd": 5,
  final int solubilitySetStart; //"solubilitySetStart": 1,
  final int widthSetStart; //"widthSetStart": 20,
  final int widthSetEnd; //"widthSetEnd": 50,
  final Iterable<Object?> wifiNotSupportVersions;
}
