import 'package:hive/hive.dart';
part 'DB2WayPointModel.g.dart';

@HiveType(typeId: 66)
class DB2WayPointModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  DB2WayPointModel({required this.responseBody});
}