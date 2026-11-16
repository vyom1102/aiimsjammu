import 'package:hive/hive.dart';

part 'ExhibitorAPIModel.g.dart';

@HiveType(typeId: 81)
class ExhibitorAPIModel extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  ExhibitorAPIModel({required this.responseBody});
}