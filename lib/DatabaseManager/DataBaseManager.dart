import 'package:hive/hive.dart';
import '../DataBaseManager/DBManager.dart';
import '../Network/APIDetails.dart';
import '../Userbox.dart';

class DataBaseManager implements DBManager {
  bool greenDataBase = true;

  // Singleton instance
  static final DataBaseManager _instance = DataBaseManager._internal();

  // Private constructor
  DataBaseManager._internal();

  // Factory constructor returning the singleton
  factory DataBaseManager() => _instance;

  // @override
  // Future<void> delete(Detail details, String bID) async {
  //   final databaseBox = details.dataBaseGetData!();
  //   await databaseBox.clear();
  // }
  

  @override
  Future<dynamic> updateData() {
    throw UnimplementedError();
  }

  @override
  Future<void> saveData(dynamic dataModel, Detail details, String bID) async {
    final databaseBox = details.dataBaseGetData!();
    databaseBox.put(bID, dataModel);
  }

  @override
  Future<void> saveDataDB2(dynamic dataModel, Detail details, String bID) async {
    final databaseBox = details.dataBaseGetDataDB2!();
    databaseBox.put(bID, dataModel);
  }

  @override
  dynamic getData(Detail details, String bID) {
    final databaseBox = details.dataBaseGetData!();
    final data = databaseBox.get(bID);
    return data;
  }

  @override
  dynamic getDataDB2(Detail details, String bID) {
    final databaseBox = details.dataBaseGetDataDB2!();
    final data = databaseBox.get(bID);
    return data;
  }

  @override
  dynamic getDataBaseKeysDB2(Detail details){
    final databaseBox = details.dataBaseGetDataDB2!();
    return databaseBox.keys;
  }

  @override
  dynamic getDataBaseValuesDB2(Detail details){
    final databaseBox = details.dataBaseGetDataDB2!();
    return databaseBox.values;
  }

  @override
  List<dynamic> getDataBaseKeys(Detail details){
    final databaseBox = details.dataBaseGetData!();
    return databaseBox.keys.toList();
  }

  @override
  dynamic getDataBaseValues(Detail details){
    final databaseBox = details.dataBaseGetData!();
    return databaseBox.values;
  }

  @override
  Future<String> getAccessToken() async {
    // await UserBox.getAccessToken();
    var signInBox = Hive.box('SignInDatabase');
    return await UserBox.getAccessToken()??"";
  }

  @override
  void updateAccessToken(String newAccessToken) {
    var signInBox = Hive.box('SignInDatabase');
    signInBox.put("accessToken", newAccessToken);
  }

  @override
  String getRefreshToken() {
    var signInBox = Hive.box('SignInDatabase');
    return signInBox.get("refreshToken");
  }

  @override
  void updateRefreshToken(String newRefreshToken) {
    var signInBox = Hive.box('SignInDatabase');
    signInBox.put("refreshToken", newRefreshToken);
  }

  @override
  void delete(Detail details, String bID) {
    // TODO: implement delete
    final databaseBox = details.dataBaseGetData!();
    databaseBox.clear();
    return;
  }

  
  


}

