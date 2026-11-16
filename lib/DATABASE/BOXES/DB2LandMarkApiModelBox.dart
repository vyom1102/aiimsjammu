import 'package:hive/hive.dart';

import '../DATABASEMODEL/DB2LandMarkApiModel.dart';


class DB2LandMarkApiModelBox{
  static Box<DB2LandMarkApiModel> getData() => Hive.box<DB2LandMarkApiModel>('DB2LandMarkApiModelFile');
}