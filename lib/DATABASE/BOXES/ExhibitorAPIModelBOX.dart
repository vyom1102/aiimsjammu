import 'package:hive/hive.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/ExhibitorAPIModel.dart';

class ExhibitorAPIModelBOX{
  static Box<ExhibitorAPIModel> getData() => Hive.box<ExhibitorAPIModel>('ExhibitorAPIModelFileNEW');
}