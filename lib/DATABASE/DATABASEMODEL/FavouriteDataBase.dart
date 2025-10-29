import 'package:hive/hive.dart';

part 'FavouriteDataBase.g.dart';

@HiveType(typeId: 4)
class FavouriteDataBaseModel extends HiveObject{
  @HiveField(0)
  FavouriteDataBaseModel favouriteDataBaseModel;

  FavouriteDataBaseModel({required this.favouriteDataBaseModel});

}