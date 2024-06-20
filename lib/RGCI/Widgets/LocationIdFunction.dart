import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Navigation.dart';

void PassLocationId(BuildContext context,String Id){
  print("devteam $Id");
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>   Navigation(directLandID: Id,),
    ),
  );

  print(Id);

}