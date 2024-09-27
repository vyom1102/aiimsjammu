
import 'package:hive/hive.dart';

class UserCredentials{
  var userInformationBox = Hive.box('UserInformation');
  String RefreshToken = "";
  String AccessToken = "";
  List<dynamic> Roles = [];
  String UserId = "";
  String UserHeight = "";
  int UserPersonWithDisability = 0;
  String UserNavigationModeSetting = "";
  String UserOrentationSetting = "";
  String UserPathDetails = '';
  String userName = '';


  String getuserName(){
    userName = userInformationBox.get('username')??'username';
    return userName;
  }


  void setUserHeight(String userheight){
    userInformationBox.put('UserHeight', userheight);
  }
  String getUserHeight(){
    UserHeight = userInformationBox.get('UserHeight')?? '5.8';
    print(userInformationBox.keys);
    return UserHeight;
  }

  void setUserPersonWithDisability(int userdisabilitytype){
    userInformationBox.put('UserDisabilityType', userdisabilitytype);
  }
  int getUserPersonWithDisability(){
    UserPersonWithDisability = userInformationBox.get('UserDisabilityType')??0;
    return UserPersonWithDisability;
  }

  void setUserNavigationModeSetting(String userNavigationModeSetting){
    userInformationBox.put('UserNavigationModeSetting', userNavigationModeSetting);
  }
  String getuserNavigationModeSetting(){
    UserNavigationModeSetting = userInformationBox.get('UserNavigationModeSetting')??'Natural Direction';
    return UserNavigationModeSetting;
  }

  void setUserOrentationSetting(String userOrentationSetting){
    userInformationBox.put('UserOrentationSetting', userOrentationSetting);
  }
  String getUserOrentationSetting(){
    UserOrentationSetting = userInformationBox.get('UserOrentationSetting')??"Explore Mode";
    return UserOrentationSetting;
  }

  void setUserPathDetails(String userUserPathDetails){
    userInformationBox.put('UserPathDetails', userUserPathDetails);
  }
  String getUserPathDetails(){
    UserPathDetails = userInformationBox.get('UserPathDetails')??"Distance in meters";
    return UserPathDetails;
  }






  bool containsAccessToken(){
    return AccessToken.length!=0;
  }

  String getRefreshToken(){
    return RefreshToken;
  }
  void setRefreshToken(String refreshToken){
    RefreshToken = refreshToken;
  }

  String getAccessToken(){
    return AccessToken;
  }
  void setAccessToken(String accessToken) async {
    AccessToken = accessToken;
  }

  List<dynamic> getRoles(){
    return Roles;
  }
  void setRoles(List<dynamic> roles){
    Roles = roles;
  }

  String getUserId(){
    return UserId;
  }
  void setUserId(String userId){
    UserId = userId;
  }
}