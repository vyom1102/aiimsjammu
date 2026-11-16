import 'package:hive/hive.dart';
part 'BuildingByVenueMapAPIModel.g.dart';

@HiveType(typeId: 75)
class BuildingByVenueMapAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  BuildingByVenueMapAPIModel({required this.responseBody});
}