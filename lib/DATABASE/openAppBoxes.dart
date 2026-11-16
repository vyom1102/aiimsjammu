import 'package:hive/hive.dart';

import 'DATABASEMODEL/BuildingAPIModel.dart';
import 'DATABASEMODEL/BuildingAllAPIModel.dart';
import 'DATABASEMODEL/DataVersionLocalModel.dart';
import 'DATABASEMODEL/LandMarkApiModel.dart';
import 'DATABASEMODEL/LocalNotificationAPIDatabaseModel.dart';

/// Registers the app's Hive adapters and opens every box the app reads with
/// `Hive.box(...)`. `Hive.init` must already have been called.
///
/// These used to be opened by `NavigationSDK.initializeapp`; navigation is now
/// the hosted web map, which keeps its own storage inside the WebView.
Future<void> openAppBoxes() async {
  _register(LandMarkApiModelAdapter());
  _register(BuildingAllAPIModelAdapter());
  _register(BuildingAPIModelAdapter());
  _register(DataVersionLocalModelAdapter());
  _register(LocalNotificationAPIDatabaseModelAdapter());

  // Cached API responses. They were written by navigation_sdk's own model
  // classes, so if an old entry can't be read the cache is dropped and refetched.
  await _openCache<LandMarkApiModel>('LandMarkApiModelFile');
  await _openCache<BuildingAllAPIModel>('BuildingAllAPIModelFile');
  await _openCache<BuildingAPIModel>('BuildingAPIModelFile');
  await _openCache<DataVersionLocalModel>('DataVersionLocalModelFile');
  await _openCache<LocalNotificationAPIDatabaseModel>(
      'LocalNotificationAPIDatabaseModel');

  for (final name in const [
    'SignInDatabase',
    'UserInformation',
    'DashboardList',
    'VersionData',
    'LocationPermission',
    'SwitchingDatabaseInfo',
    'user',
  ]) {
    if (!Hive.isBoxOpen(name)) await Hive.openBox(name);
  }
}

void _register<T>(TypeAdapter<T> adapter) {
  if (!Hive.isAdapterRegistered(adapter.typeId)) Hive.registerAdapter(adapter);
}

Future<void> _openCache<T>(String name) async {
  if (Hive.isBoxOpen(name)) return;
  try {
    await Hive.openBox<T>(name);
  } catch (e) {
    print('Hive box $name unreadable ($e), clearing it');
    await Hive.deleteBoxFromDisk(name);
    await Hive.openBox<T>(name);
  }
}
