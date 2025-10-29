import 'package:hive/hive.dart';

import '../DATABASEMODEL/BeaconAPIModel.dart';


class BeaconAPIModelBOX{
  static Box<BeaconAPIModel> getData() => Hive.box<BeaconAPIModel>('BeaconAPIModelFile');
}