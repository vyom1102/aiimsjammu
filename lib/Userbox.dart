
import 'package:hive/hive.dart';


class UserBox {
  static const _userBoxName = 'userBox';

  // Authentication tokens
  static Future<String?> getAccessToken() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('accessToken');
  }

  static Future<String?> getRefreshToken() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('refreshToken');
  }

  // User identification
  static Future<String?> getUserId() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('userId');
  }

  static Future<String?> getResponseType() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('responseType');
  }

  // Basic user info
  static Future<String?> getName() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('name');
  }

  static Future<String?> getEmail() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('email');
  }
  static Future<int?> getCode() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('code');
  }
  static Future<String?> getMobile() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('mobile');
  }

  static Future<String?> getGender() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('gender');
  }

  static Future<String?> getUserType() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('userType');
  }

  // Personal details
  static Future<String?> getDob() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('dob');
  }

  static Future<String?> getAddress() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('address');
  }

  static Future<String?> getCountry() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('country');
  }

  static Future<String?> getState() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('state');
  }

  static Future<String?> getCity() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('city');
  }

  static Future<String?> getFilename() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('filename');
  }

  static Future<String?> getRegistrationNumber() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('registrationNumber');
  }

  // Boolean values
  static Future<bool?> getPaidUser() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('paidUser');
  }

  static Future<bool?> getDeleted() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('deleted');
  }

  // Array values
  static Future<List<dynamic>?> getRoles() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('roles');
  }
  static Future<void> setIsChecker(bool value) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('isChecker', value);
  }

  static Future<bool> isChecker() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('isChecker', defaultValue: false);
  }

  static Future<List<dynamic>?> getDisabilities() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('disabilities');
  }

  static Future<List<dynamic>?> getFilters() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('filters');
  }

  static Future<List<dynamic>?> getCategories() async {
    final box = await Hive.openBox(_userBoxName);
    return box.get('categories');
  }

  // static Future<List<dynamic>?> getFavourites() async {
  //   final box = await Hive.openBox(_userBoxName);
  //   return box.get('favourites');
  // }
  static Future<Map<String, List<String>>?> getFavourites() async {
    // await UserService.fetchAndStoreFavourites();
    final box = await Hive.openBox(_userBoxName);
    final data = box.get('favourites');

    if (data is Map) {
      return Map<String, List<String>>.fromEntries(
        data.entries.map((e) => MapEntry(e.key, List<String>.from(e.value))),
      );
    }
    return null;
  }


  // static Future<Map<String, List<String>>?> getFavourites() async {
  //   await UserService.fetchAndStoreFavourites();
  //   final box = await Hive.openBox(_userBoxName);
  //   final data = box.get('favourites');
  //
  //   if (data is Map) {
  //     return Map<String, List<String>>.fromEntries(
  //       data.entries.map((e) => MapEntry(e.key, List<String>.from(e.value))),
  //     );
  //   }
  //   return null;
  // }

  // Utility methods
  static Future<bool> isUserRegistered() async {
    final name = await getName();
    return name != null && name.isNotEmpty;
  }

  static Future<Map<String, dynamic>> getAllUserData() async {
    final box = await Hive.openBox(_userBoxName);
    return Map<String, dynamic>.from(box.toMap());
  }

  static Future<void> clearUserData() async {
    final box = await Hive.openBox(_userBoxName);
    await box.clear();
  }

  // Setter methods (if needed for updating specific fields)
  static Future<void> setAccessToken(String token) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('accessToken', token);
  }

  static Future<void> setRefreshToken(String token) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('refreshToken', token);
  }
  static Future<void> setDisabilities(List<String> disabilities) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('disabilities', disabilities);
  }
  static Future<void> updateFavourites(List<dynamic> favourites) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('favourites', favourites);
  }
  static Future<void> saveFavourites(Map<String, dynamic> favourites) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('favourites', favourites);
  }
  static Future<void> setName(String name) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('name', name);
  }
  static Future<void> setEmail(String email) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('email', email);
  }
  static Future<void> setMobile(String mobile) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('mobile', mobile);
  }

  static Future<void> setFilename(String filename) async {
    final box = await Hive.openBox(_userBoxName);
    await box.put('filename', filename);
  }
  static Future<void> saveUserData(Map<String, dynamic> data, String accessToken, String refreshToken) async {
    final box = await Hive.openBox(_userBoxName);

    await box.put('userId', data['_id']);
    await box.put('name', data['name']);
    await box.put('email', data['email']);
    await box.put('paidUser', data['paidUser']);
    await box.put('deleted', data['deleted']);
    // await box.put('roles', data['roles']);
    // await box.put('accessToken', accessToken);
    // await box.put('refreshToken', refreshToken);
    await box.put('userType', data['userType']);
    await box.put('dob', data['dob']);
    await box.put('address', data['address']);
    await box.put('country', data['country']);
    await box.put('state', data['state']);
    await box.put('city', data['city']);
    await box.put('filename', data['filename']);
    await box.put('gender', data['gender']);
    await box.put('mobile', data['mobile']);
    await box.put('registrationNumber', data['registrationNumber']);

    // Store arrays
    await box.put('disabilities', data['disabilities'] ?? []);
    await box.put('filters', data['filters'] ?? []);
    await box.put('categories', data['categories'] ?? []);
    await box.put('favourites', data['favourites'] ?? []);
  }
}