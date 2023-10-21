import 'package:flutter/foundation.dart';

@immutable
class DeviceGuide {

  const DeviceGuide({
    required  this.companyId,
    required  this.guideImage,
    required this.guideName,
    required this.hardwareSeriesId,
    required this.helpVideo,
    required this.id,
    required this.machineName,
    required this.precisionId,
    required this.printDensityDefault,
    required this.printDensityMax,
    required this.printDensityMin,
    required this.rfid,
    required this.sort,
    required this.typeId,
    required this.updateTime,
    required this.wifi,
  });

  factory DeviceGuide.fromJson(Map<String, dynamic> json) {
    return DeviceGuide(
      companyId: json['company_id'],
      guideImage: json['guide_image'],
      guideName: json['guide_name'],
      hardwareSeriesId: json['hardware_series_id'],
      helpVideo: json['helpVideo'],
      id: json['id'],
      machineName: json['machine_name'],
      precisionId: json['precision_id'],
      printDensityDefault: json['print_density_default'],
      printDensityMax: json['print_density_max'],
      printDensityMin: json['print_density_min'],
      rfid: json['rfid'],
      sort: json['sort'],
      typeId: json['type_id'],
      updateTime: json['update_time'],
      wifi: json['wifi'],
    );
  }
  final int companyId;
  final String guideImage;
  final String guideName;
  final String hardwareSeriesId;
  final String helpVideo;
  final String id;
  final String machineName;
  final int precisionId;
  final int printDensityDefault;
  final int printDensityMax;
  final int printDensityMin;
  final int rfid;
  final int sort;
  final int typeId;
  final String updateTime;
  final int wifi;

}