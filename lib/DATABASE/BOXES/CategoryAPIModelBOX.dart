import 'package:hive/hive.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/CategoryAPIModel.dart';



class CategoryAPIModelBOX{
  static Box<CategoryAPIModel> getData() => Hive.box<CategoryAPIModel>('CategoryAPIModelFile');
}