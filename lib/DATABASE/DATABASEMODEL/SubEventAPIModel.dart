import 'package:hive/hive.dart';
part 'SubEventAPIModel.g.dart';

@HiveType(typeId: 83)
class SubEventAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  SubEventAPIModel({required this.responseBody});
}