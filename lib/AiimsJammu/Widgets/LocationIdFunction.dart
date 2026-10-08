import 'package:iwaymaps/service/map_calling_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



void PassLocationId(BuildContext context,String Id){
  print("devteam $Id");
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => Navigation(directLandID: Id,),
  //   ),
  // );

    NavigationService.startLandmarkNavigation(context, Id);
  print(Id);

}