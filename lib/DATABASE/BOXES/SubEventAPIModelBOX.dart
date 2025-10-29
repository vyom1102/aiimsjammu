import 'package:hive/hive.dart';
import 'package:iwaymaps/DATABASE/DATABASEMODEL/SubEventAPIModel.dart';

import '../DATABASEMODEL/BeaconAPIModel.dart';


class SubEventAPIModelBOX{
  static Box<SubEventAPIModel> getData() => Hive.box<SubEventAPIModel>('SubEventAPIModelFile');
}