
import 'child_property.dart';
import 'parent_property.dart';

class DeviceModuleConsumable { //"childProperties": {}

  DeviceModuleConsumable({
    required this.parentProperty,
    required this.childProperties,
  });

  factory DeviceModuleConsumable.fromJson(Map<String, dynamic> json) {
    return DeviceModuleConsumable(
      parentProperty: ParentProperty.fromJson(json['parentProperty']),
      childProperties: (json['childProperties'] as List<dynamic>)
          .map((childJson) => ChildProperty.fromJson(childJson as Map<String, dynamic>))
          .toList(),
    );
  }

  final ParentProperty parentProperty; //"parentProperty": {}
  final Iterable<ChildProperty> childProperties;
}
