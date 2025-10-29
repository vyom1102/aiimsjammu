
import 'package:hive/hive.dart';

import '../DATABASEMODEL/BuildingByVenueMapAPIModel.dart';

class BuildingByVenueAPIBOX{
  static Box<BuildingByVenueMapAPIModel> getData() => Hive.box<BuildingByVenueMapAPIModel>('BuildingByVenueMapModelFile');
}