import 'package:hive/hive.dart';
part 'DB2BuildingByVenueAPIModel.g.dart';


@HiveType(typeId: 70)
class DB2BuildingByVenueAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2BuildingByVenueAPIModel({required this.responseBody});
}