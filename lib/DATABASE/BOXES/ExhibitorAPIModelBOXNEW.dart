import 'package:hive/hive.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/ExhibitorAPIModel.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/ExhibitorAPIModelNEW.dart';

class ExhibitorAPIModelBOXNEW{
  static Box<ExhibitorAPIModelNEW> getData() => Hive.box<ExhibitorAPIModelNEW>('ExhibitorAPIModelFileNEW');
}