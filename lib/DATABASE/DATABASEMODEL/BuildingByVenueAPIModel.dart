import 'package:hive/hive.dart';
part 'BuildingByVenueAPIModel.g.dart';

@HiveType(typeId: 26)
class BuildingByVenueAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  BuildingByVenueAPIModel({required this.responseBody});
}