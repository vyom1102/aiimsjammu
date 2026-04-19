import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigation_sdk/navigation_sdk.dart';
import 'package:unified_map_view/unified_map_view.dart';
import 'package:unified_map_view/maplibre.dart';

import '../../Navigation.dart';
import '../../config.dart';


void PassLocationId(BuildContext context,String Id){
  print("devteam $Id");
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => Navigation(directLandID: Id,),
  //   ),
  // );
  NavigationSDK.callWithLandMarkId(
      context,
      "AIIMSJAMMU",
      Id,
      Color(0xFFEC5B13),
      false,
      AppConfig.languageCode,
      mapType: MapProvider.mapLibre, providers: {MapProvider.mapLibre : MaplibreMapProvider()}
  );

  print(Id);

}