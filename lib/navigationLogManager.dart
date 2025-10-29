import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/Network/APIDetails.dart';
import 'package:iwaymaps/config.dart';
import 'Userbox.dart';
import 'navigationLogModel.dart';
import 'package:http/http.dart' as http;
class NavigationLogManager {
  static final NavigationLogManager _instance = NavigationLogManager._internal();
  late List<NavigationLog> _logs;
  late Box _box;
  factory NavigationLogManager(){
    return _instance;
  }
  NavigationLogManager._internal() {
    _logs = [];
  }
  /// Initialize Hive and load logs
  Future<void> initialize() async {
    _box = await Hive.openBox('navigationLogs');
    _loadLogsFromHive();
  }
  /// Log a navigation event
  /// Log a navigation event
  void logNavigation(NavigationLog log) {
    // Find if there's already a log for this user going from source to destination
    // that hasn't ended yet (endTime is null)
    int existingIndex = _logs.indexWhere((l) =>
        l.source == log.source &&
        l.destination == log.destination  // Only match ongoing navigation
    );


    if (existingIndex != -1) {
      // Update the existing log instead of adding a new one
      _logs[existingIndex] = log;
      print("Navigation Log Updated: ${log.toJson()}");
    } else {
      // Add new log if it doesn't exist
      _logs.add(log);
      print("Navigation Log Added: ${log.toJson()}");
    }
    _saveLogsToHive();
  }
  /// Save logs to Hive
  void _saveLogsToHive(){
    List<String> encodedLogs = _logs.map((log) => jsonEncode(log.toJson())).toList();
    _box.put('logs', encodedLogs);
  }
  // Load logs from Hive
  void _loadLogsFromHive(){
    final storedLogs = _box.get('logs') as List<dynamic>?;
    if (storedLogs != null){
      _logs = storedLogs.map((log) => NavigationLog.fromJson(jsonDecode(log))).toList();
    }
  }
  /// Sync logs to the server
  Future<void> syncLogsToServer() async{
    // var signInBox = Hive.box('SignInDatabase');
    // String accessToken = signInBox.get("accessToken");
    String? accesstoken = await UserBox.getAccessToken();
    if (_logs.isEmpty) return;
    try{
      print("navigation logs::${_logs}");
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/secured/save-navigation-logs"),
        headers:{
          'Content-Type': 'application/json',
          'x-access-token': accesstoken!,
        },
        body: jsonEncode(_logs.map((log) => log.toJson()).toList()),
      );
      if (response.statusCode == 200){
        print("Navigation Logs Synced: ${response.body}");
        _logs.clear();
        _box.clear();
      }else{
        print('Failed to sync navigation logs: ${response.body}');
      }
    }catch (e){
      print('Error syncing navigation logs: $e');
    }
  }
}