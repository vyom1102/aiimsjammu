
import 'package:hive/hive.dart';
import '../DATABASEMODEL/DB2BuildingByVenueMapAPIModel.dart';

class DB2BuildingByVenueMapAPIBOX{
  static Box<DB2BuildingByVenueMapAPIModel> getData() => Hive.box<DB2BuildingByVenueMapAPIModel>('DB2BuildingByVenueMapModelFile');
}