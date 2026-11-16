import 'package:hive/hive.dart';
part 'FingerPrintingAPIModel.g.dart';


@HiveType(typeId: 71)
class FingerPrintingAPIModel extends HiveObject{
  @HiveField(0)
  Map<String, dynamic> responseBody;

  FingerPrintingAPIModel({required this.responseBody});
}