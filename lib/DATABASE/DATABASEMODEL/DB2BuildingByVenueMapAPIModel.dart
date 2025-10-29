import 'package:hive/hive.dart';
part 'DB2BuildingByVenueMapAPIModel.g.dart';


@HiveType(typeId: 77)
class DB2BuildingByVenueMapAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2BuildingByVenueMapAPIModel({required this.responseBody});
}