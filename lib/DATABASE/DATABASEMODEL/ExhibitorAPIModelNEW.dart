import 'package:hive/hive.dart';

part 'ExhibitorAPIModelNEW.g.dart';

@HiveType(typeId: 86)
class ExhibitorAPIModelNEW extends HiveObject{
  @HiveField(0)
  List<dynamic> responseBody;

  ExhibitorAPIModelNEW({required this.responseBody});
}