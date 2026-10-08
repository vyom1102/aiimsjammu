import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Device manufacturer and model, matching what the `device_meta` package
/// reported (it pulled in nylo_support, which no longer compiles).
class DeviceMeta {
  String? manufacturer;
  String? model;

  DeviceMeta._(this.manufacturer, this.model);

  static Future<DeviceMeta> init({String? storageKey}) async {
    final plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final info = await plugin.webBrowserInfo;
      return DeviceMeta._('n/a', info.browserName.name);
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await plugin.androidInfo;
        return DeviceMeta._(info.manufacturer, info.model);
      case TargetPlatform.iOS:
        final info = await plugin.iosInfo;
        return DeviceMeta._('Apple', info.model);
      default:
        return DeviceMeta._(null, null);
    }
  }
}
