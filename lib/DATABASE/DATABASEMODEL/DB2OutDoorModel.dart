import 'package:hive/hive.dart';
part 'DB2OutDoorModel.g.dart';

@HiveType(typeId: 96)
class DB2OutDoorModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2OutDoorModel({required this.responseBody});
}