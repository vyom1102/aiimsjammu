import 'package:hive/hive.dart';
part 'SessionAPIModel.g.dart';


@HiveType(typeId: 82)
class SessionAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  SessionAPIModel({required this.responseBody});
}