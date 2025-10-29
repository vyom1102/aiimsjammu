import 'package:hive/hive.dart';

import '../DATABASEMODEL/DB2GlobalAnnotationAPIModel.dart';

class DB2GlobalAnnotationAPIModelBOX{
  static Box<DB2GlobalAnnotationAPIModel> getData() => Hive.box<DB2GlobalAnnotationAPIModel>('DB2GlobalAnnotationAPIFile');
}
