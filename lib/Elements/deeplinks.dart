import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../service/map_calling_function.dart';

class Deeplink{
  static String? initialDocId; // To store the initial doctor's ID from the deep link
  static String? initialServiceId;
  static String? accessToken;
  static String? bid;
  static String landmarkID = "";
  static String? source;
  static var signinBox = Hive.box('SignInDatabase');
  static bool gotDeepLink = false;

  static Future<void> deeplinkConditions(Uri?uri,BuildContext context)async{
    if (uri != null) {
      print('Received deep link: ${uri.toString()}');
      // if (uri.toString().contains("rgci.com") && !gotDeepLink) {
      //   gotDeepLink = true;
      //   await rgciDeepLink(uri, context, "rgci.com");
      // }else if(uri.toString().contains("iwaymaps.com") && !gotDeepLink){
      //   gotDeepLink = true;
      //   await iwaymapsDeepLink(uri, context, "iwaymaps.com");
      // }else
        if (uri.toString().contains("aiimsj.com") && !gotDeepLink){
        gotDeepLink = true;
        await aiimsjDeepLink(uri, context, "aiimsj.com");
      }
    }
    return ;
  }

  static Future<void> aiimsjDeepLink(Uri?uri,BuildContext context,String appName)async{
    if (uri.toString().contains("iwayplus://${appName}/doctor")) {
      final docId = uri!.queryParameters['docId'];
      if (docId != null) {
        initialDocId = docId;
      }
    } else if (uri.toString().contains("iwayplus://${appName}/service")) {
      final serviceId = uri!.queryParameters['serviceId'];
      if (serviceId != null) {
        initialServiceId = serviceId;
      }
    } else if (uri.toString().contains("iwayplus://auth")) {
      Navigator.pushNamed(context, 'signIn');
    } else if(uri.toString().contains("iwayplus://${appName}/landmark")){
      final b = uri!.queryParameters['bid'];
      final l = uri!.queryParameters['landmark'];
      final s = uri!.queryParameters['source'];
      if (b != null) {
        bid = b;
      }
      if (l != null) {
        landmarkID = l;
      }
      if(s != null){
        source = s;
      }

      print("bid  landmarkID  source $bid <-----> $landmarkID <------> $source");
      // `source` localizes the user AT that landmark; `landmark` opens it as
      // the destination.
      if (source != null && source!.isNotEmpty) {
        NavigationService.startLandmarkLocalization(context, source!);
      } else {
        NavigationService.startLandmarkNavigation(context, landmarkID);
      }
    }

    final accessToke = uri!.queryParameters['token'];
    if (accessToke != null) {
      accessToken = accessToke;

      signinBox.put('rgciCareAccessToken', accessToke);
    }
  }
  static String extractDomain(Uri uri) {
    // Convert Uri to string and use the same regular expression to match the domain part of the URL
    final regex = RegExp(r'\/iway-apps\/([^\/]+)\/');
    final match = regex.firstMatch(uri.toString());

    // If a match is found, return the matched group, otherwise return an empty string
    if (match != null && match.groupCount > 0) {
      return match.group(1) ?? '';
    }

    return '';
  }
}