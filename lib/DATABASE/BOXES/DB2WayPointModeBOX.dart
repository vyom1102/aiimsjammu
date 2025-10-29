import 'package:hive/hive.dart';
import '../DATABASEMODEL/DB2WayPointModel.dart';

class DB2WayPointModeBOX{
  static Box<DB2WayPointModel> getData() => Hive.box<DB2WayPointModel>('DB2WayPointModelFile');
}