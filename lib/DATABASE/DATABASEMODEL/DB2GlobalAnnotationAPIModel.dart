import 'package:hive/hive.dart';
part 'DB2GlobalAnnotationAPIModel.g.dart';

@HiveType(typeId: 72)
class DB2GlobalAnnotationAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  DB2GlobalAnnotationAPIModel({required this.responseBody});
}