import 'package:hive/hive.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/SessionAPIModel.dart';

class SessionAPIModelBOX{
  static Box<SessionAPIModel> getData() => Hive.box<SessionAPIModel>('SessionAPIModelFile');
}