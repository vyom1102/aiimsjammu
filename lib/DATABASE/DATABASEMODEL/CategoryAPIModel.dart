import 'package:hive/hive.dart';
part 'CategoryAPIModel.g.dart';


@HiveType(typeId: 80)
class CategoryAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  CategoryAPIModel({required this.responseBody});
}