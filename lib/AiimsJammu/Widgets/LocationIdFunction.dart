import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigation_sdk/navigation_sdk.dart';
import 'package:unified_map_view/unified_map_view.dart';
import 'package:unified_map_view/maplibre.dart';

import '../../Navigation.dart';


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
      Color(0xFF0097A7),
      false,
      AppConfig.languageCode,
      mapType: MapProvider.mapLibre, providers: {MapProvider.mapLibre : MaplibreMapProvider()}
  );

  print(Id);

}