
import 'package:hive/hive.dart';

import '../DATABASEMODEL/DB2OutDoorModel.dart';

class DB2OutDoorModeBOX{
  static Box<DB2OutDoorModel> getData() => Hive.box<DB2OutDoorModel>('DB2OutDoorModelFile');
}