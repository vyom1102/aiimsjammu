
import 'package:hive/hive.dart';

import '../DATABASEMODEL/FingerPrintingAPIModel.dart';

class FingerPrintingAPIModelBOX{
  static Box<FingerPrintingAPIModel> getData() => Hive.box<FingerPrintingAPIModel>('FingerPrintingModelFile');
}