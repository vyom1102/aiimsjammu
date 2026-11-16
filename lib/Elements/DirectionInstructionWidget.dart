import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_svg/svg.dart';
import '../Elements/locales.dart';
import '../directionClass.dart';

class DirectionInstructionWidget extends StatefulWidget {

  String StartName;
  String StartBuildingName;
  int StartFloor;
  int Turns;
  int TotalDistanceInMeter;

  String EndName;
  String EndBuildingName;
  int EndFloor;

  double FirstHeight;
  double SecondHeight;
  double ThirdHeight;
  double ForthHeight;

  String LiftString;

  List<direction> directionList;
  bool IsMultiFloor;
  bool IsMultiBuilding;
  String BuildingID;

  bool reverse;
  int totalSourceTurns;
  int totalDestinationTurns;
  int totalOutDoorTurns;
  // int totalSourceDistInMeterInMeter;
  // int totalDestinationDistInMeterInMeter;
  int totalSourceDistInMeter;
  int totalDestinationDistInMeter;
  int totalOutdoorDist;
  //for multibuilding 2nd means reverse card

  DirectionInstructionWidget(
      {required this.StartName,
        required this.StartBuildingName,
        required this.StartFloor,
        required this.EndName,
        required this.EndBuildingName,
        required this.EndFloor,
        required this.FirstHeight,
        required this.SecondHeight,
        required this.ThirdHeight,
        required this.ForthHeight,
        required this.LiftString,
        required this.directionList,
        required this.IsMultiFloor,
        required this.IsMultiBuilding,
        required this.Turns,
        required this.TotalDistanceInMeter,
        required this.BuildingID,
        this.reverse = false,
        this.totalSourceTurns=0,
        this.totalDestinationTurns=0,
        this.totalOutDoorTurns=0,
        this.totalSourceDistInMeter=0,
        this.totalDestinationDistInMeter=0,
        this.totalOutdoorDist=0
      });

  @override
  _DirectionInstructionWidgetState createState() =>
      _DirectionInstructionWidgetState();
}

class _DirectionInstructionWidgetState extends State<DirectionInstructionWidget> {
  bool ListExpand = false;

  double defaultSpace = 12.5;
  double defaultLineWidth = 3;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    int turns = widget.reverse
        ? (widget.totalDestinationTurns == 0 ? 0 : widget.totalDestinationTurns)
        : (widget.totalSourceTurns == 0 ? 0 : widget.totalSourceTurns);

    // Step 2: Determine distance in meters
    int distanceInFeet = widget.reverse
        ? widget.totalDestinationDistInMeter
        : widget.totalSourceDistInMeter;

    int distanceInMeters = (distanceInFeet);

    // Step 3: Compose the full string
    if (!widget.IsMultiBuilding) {
      distanceInMeters = (widget.TotalDistanceInMeter!);
    }
    String firstElement = "";
    if(turns == 0){
      firstElement = widget.directionList[0].turnDirection!;
    }

    return Semantics(
      label: "",
      child: GestureDetector(
        onTap: (){
          ListExpand = !ListExpand;
        },
        child: Container(
          margin: EdgeInsets.only(top: !widget.IsMultiBuilding? 20:10,),
          decoration: widget.IsMultiBuilding?BoxDecoration(
            border: Border.all(
              color: Colors.black12, // Color of the outline
              width: 2, // Width of the outline
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,// Optional: Rounded corners
          ) : BoxDecoration(),
          padding: widget.IsMultiBuilding? EdgeInsets.only(left: 0,top: 15,right: 10,bottom: 15):EdgeInsets.only(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 14,),
              Semantics(
                label: "From ${widget.StartName}, ${widget.Turns} Turns to reach ${!widget.IsMultiBuilding || widget.reverse?widget.EndName : widget.StartBuildingName}",
                child: Container(
                  width: screenWidth*0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: widget.reverse?6:defaultLineWidth-2,),
                          widget.reverse? Stack(
                            alignment: widget.IsMultiBuilding && !widget.reverse?Alignment.bottomCenter:Alignment.topCenter,
                            children: [
                              Container(
                                height:24,
                                width: defaultLineWidth,
                                color: Color(0xff132F59),
                              ),
                              Container(
                                width: 16, // Width of the circle
                                height: 16, // Height of the circle
                                decoration: BoxDecoration(
                                  color: Color(0xff132F59), // Color of the circle
                                  shape: BoxShape.circle, // Makes the container a circle
                                ),
                              )
                            ],
                          ) : Container(
                            child: SvgPicture.asset(
                              "assets/DirectionInstruction_sourceIcon.svg",height: 25,),
                          ),
                          SizedBox(width: defaultSpace,),
                          widget.reverse? ExcludeSemantics(
                            child: Text(
                              "Entering ${widget.EndBuildingName}",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff3f3f46),
                                height: 24/18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ): ExcludeSemantics(
                            child: Text(
                              widget.StartName,
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff3f3f46),
                                height: 24/18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      Row(
                          children: [
                            SizedBox(width: defaultSpace,),
                            widget.reverse? Container() : Container(width: defaultLineWidth,color: Color(0xff132F59),height: widget.reverse?25:40,),
                            SizedBox(width: defaultSpace*2,),
                            widget.reverse? Container() : ExcludeSemantics(
                              child: Container(
                                  padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: widget.IsMultiBuilding?Color(0xffD2F9EF) : Color(0xff6527F5),
                                  ),
                                  child: widget.IsMultiBuilding? Text("${widget.StartBuildingName} - Floor ${widget.StartFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.black)):
                                  Text("Floor ${widget.StartFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))),
                            ),
                          ]
                      ),

                      // 2 Turns(11 m)
                      widget.LiftString != "" ?
                      //for single floor in that widget.LiftString will be null
                      ExcludeSemantics(
                        child: Row(
                          children: [
                            SizedBox(width: defaultSpace,),
                            Container(height: 54,width: defaultLineWidth,color: Color(0xff132F59),),
                            Column(
                              children: [
                                SizedBox(width: defaultSpace,),
                                Row(
                                  children: [
                                    ListExpand? Container(
                                      height: 35,
                                      width: 18,
                                      margin: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.keyboard_arrow_up),
                                    ) : Container(
                                      height: 35,
                                      width: 18,
                                      margin: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    !ListExpand? Container(child:  Text(
                                      widget.LiftString,
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff000000),
                                        height: 20/14,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),) : Container(child:  Text(
                                      widget.LiftString,
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff000000),
                                        height: 20/14,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),),
                                  ],
                                ),
                                SizedBox(
                                  width: screenWidth*0.7, // Set based on available width
                                  child: Divider(
                                    thickness: 1,
                                    color: Color(0xffE5E7EB),
                                    indent: 25,
                                    endIndent: 10,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ) :
                      //for multi floor when the widget.LiftString is given
                      ExcludeSemantics(
                        child: Row(
                          children: [
                            SizedBox(width: defaultSpace,),
                            Container(height: 54,width: defaultLineWidth,color: Color(0xff132F59),),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: defaultSpace+5,),
                                    ListExpand? Container(
                                      height: 35,
                                      width: 18,
                                      margin: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.keyboard_arrow_up),
                                    ) : Container(
                                      height: 35,
                                      width: 18,
                                      margin: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.keyboard_arrow_down),
                                    ),
                                    !ListExpand? Container(child:  Text(
                                      turns==0?"$firstElement":"$turns Turns (${distanceInMeters}m)",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff000000),
                                        height: 20/14,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),) : Container(child:  Text(
                                      turns==0?"$firstElement":"$turns Turns (${distanceInMeters}m)",
                                      style: const TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff000000),
                                        height: 20/14,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),),
                                    // ListExpand? SizedBox(height: 20,):Container(),
                                  ],
                                ),
                                SizedBox(
                                  width: screenWidth*0.7, // Set based on available width
                                  child: Divider(
                                    thickness: 1,
                                    color: Color(0xffE5E7EB),
                                    indent: 25,
                                    endIndent: 10,
                                  ),
                                )

                              ],
                            ),

                          ],
                        ),
                      ),


                      ListView.builder(
                        itemCount: ListExpand?widget.directionList.length : min(widget.directionList.length, 0),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0,bottom: 0),
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final direction = widget.directionList[index];
                          String extractedString = "";

                          if((direction.turnDirection??"").substring(0,4).toLowerCase() == "take"){
                            RegExp regExp = RegExp(r'Lift');
                            Match? match = regExp.firstMatch(direction.turnDirection!);
                            if (match != null) {
                              extractedString = match.group(0)!;
                              // print('Extracted: $extractedString'); // Output: Lift
                            } else {
                              // print('No match found.');
                              // print(direction.distanceToNextTurnInFeet);
                            }
                          }



                          return Semantics(
                            label:index==widget.directionList.length-1? "${direction.turnDirection} ${((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurnInFeet}" :"${((direction.distanceToNextTurnInFeet!=null)?direction.distanceToNextTurnInFeet!*0.3048:1*0.3048).ceil()} m"}, you'll reach ${!widget.IsMultiBuilding || widget.reverse?widget.EndName:widget.StartBuildingName}":"${direction.turnDirection} ${((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurnInFeet}" :"${((direction.distanceToNextTurnInFeet!=null)?direction.distanceToNextTurnInFeet!*0.3048:1*0.3048).ceil()} m"}",
                            excludeSemantics: true,
                            child: Container(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: (index == ((widget.directionList.length/2) -1).floor() && !widget.IsMultiFloor)?0:(widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take")?0:defaultSpace,),
                                      (index == ((widget.directionList.length/2) -1).floor() && !widget.IsMultiFloor)?
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: 68,
                                            width: defaultLineWidth, // narrow vertical line
                                            color: Color(0xff132F59),
                                          ),
                                          SvgPicture.asset(
                                            "assets/DirectionInstruction_manImage.svg",
                                            height: 28,
                                          ),
                                        ],
                                      ) : (widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take")?

                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(height: 118,color: Color(0xffFB6B00),width: defaultLineWidth,),
                                          Container(
                                            height: 118,
                                            child:Column(

                                                children: [
                                                  Container(
                                                    width: 26, // Width of the circle
                                                    height: 16, // Height of the circle
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff132F59), // Color of the circle
                                                      shape: BoxShape.circle, // Makes the container a circle
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  SvgPicture.asset(
                                                    "assets/DirectionInstruction_LiftIcon.svg",
                                                    height: 28,
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    width: 26, // Width of the circle
                                                    height: 16, // Height of the circle
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff132F59), // Color of the circle
                                                      shape: BoxShape.circle, // Makes the container a circle
                                                    ),
                                                  ),
                                                ]
                                            ),

                                          )

                                        ],)
                                          :
                                      Container(height: 68,color: Color(0xff132F59),width: defaultLineWidth,),
                                      SizedBox(width: (index == ((widget.directionList.length/2) -1).floor() && !widget.IsMultiFloor)?defaultSpace:(widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take")?defaultSpace:defaultSpace*2,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: screenHeight*0.02,):SizedBox(height: 3,),
                                                  widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? ExcludeSemantics(
                                                    child: Text(
                                                      (direction.turnDirection??""),
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xff3f3f46),
                                                        height: 23/16,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ): ExcludeSemantics(
                                                    child: Text(
                                                      (direction.turnDirection??""),
                                                      style: TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xff0e0d0d),
                                                        height: 25 / 16,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  SizedBox(height: 1,),
                                                  widget.IsMultiFloor && extractedString.toLowerCase() =="lift"? Container(
                                                    margin: EdgeInsets.only(top: 16),
                                                    child: Row(
                                                      children: [
                                                        ExcludeSemantics(
                                                          child: Text(
                                                            "Press",
                                                            style: const TextStyle(
                                                              fontFamily: "Roboto",
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w400,
                                                              color: Color(0xff8d8c8c),
                                                              height: 20 / 14,
                                                            ),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets.only(left: 10,right: 10),
                                                          width: 25, // Set the width and height to make the container a circle
                                                          height: 25,
                                                          decoration: BoxDecoration(
                                                            color: Color(0xffA606D2), // Background color of the circle
                                                            shape: BoxShape.circle, // Makes the container circular
                                                          ),
                                                          alignment: Alignment.center, // Center the text inside the circle
                                                          child: Text(
                                                            direction.liftDestinationFloor.toString(), // Your text here
                                                            style: const TextStyle(
                                                              fontFamily: "Roboto",
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w400,
                                                              color: Colors.white,
                                                              height: 25/16,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        ExcludeSemantics(
                                                          child: Text(
                                                            "button in the lift",
                                                            style: const TextStyle(
                                                              fontFamily: "Roboto",
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w400,
                                                              color: Color(0xff000000),
                                                              height: 25/16,
                                                            ),
                                                            textAlign: TextAlign.left,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ) :direction.distanceToNextTurnInFeet == null? Container(
                                                      child : Text(
                                                        "2 min",
                                                        style: const TextStyle(
                                                          fontFamily: "Roboto",
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w400,
                                                          color: Color(0xffa1a1aa),
                                                          height: 20/14,
                                                        ),
                                                        textAlign: TextAlign.left,
                                                      )
                                                  ) : ExcludeSemantics(
                                                    child: Text(
                                                      ((direction.turnDirection??"").substring(0,4)=="Take")? "${direction.distanceToNextTurnInFeet}" :"${((direction.distanceToNextTurnInFeet??0)*0.3048).ceil()} m",
                                                      style: const TextStyle(
                                                        fontFamily: "Roboto",
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xff8d8c8c),
                                                        height: 20 / 14,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ) ,
                                                  widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: screenHeight*0.02,):SizedBox(height: 3,),
                                                  // Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,),
                                                  SizedBox(
                                                    width: screenWidth*0.65, // Set based on available width
                                                    child: Divider(
                                                      thickness: 1,
                                                      color: Color(0xffE5E7EB),
                                                      indent: 25,
                                                      endIndent: 10,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ) ,
                                      Spacer(),
                                      widget.IsMultiBuilding && !ListExpand? Container(): widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
                                          child : Text(
                                            extractedString.toLowerCase() == "lift"? "2 min":"",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xffa1a1aa),
                                              height: 20/14,
                                            ),
                                            textAlign: TextAlign.left,
                                          )
                                      ) : Container(
                                        height: 35,
                                        width: 35,
                                        child: getCustomIcon((direction.turnDirection??""), context),
                                      ),

                                    ],
                                  ),

                                  // SizedBox(height: 2,),
                                  // widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? Container(
                                  //     margin: EdgeInsets.only(top:10),
                                  //     child: Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,)): Container(),
                                  // widget.IsMultiFloor && (direction.turnDirection??"").substring(0,4)=="Take"? SizedBox(height: 20,): Container(),
                                  // !ListExpand? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),


                                ],

                              ),
                            ),
                          );
                        },
                      ),
                      // !ListExpand? Divider(thickness: 1,color: Color(0xffE5E7EB),indent: 20,endIndent: 30,): Container(),
                      Row(
                        children: [
                          SizedBox(width: !widget.IsMultiBuilding && widget.reverse?defaultSpace:widget.IsMultiBuilding && !widget.reverse?6:0,),
                          !widget.IsMultiBuilding && widget.reverse?Container(height: 45,width: defaultLineWidth,color:Color(0xff132F59),) : Stack(
                            alignment: widget.IsMultiBuilding && !widget.reverse?Alignment.bottomCenter:Alignment.topCenter,
                            children: [
                              Container(
                                height:35,
                                width: defaultLineWidth,
                                color: Color(0xff132F59),
                              ),
                              widget.IsMultiBuilding && !widget.reverse? Container(
                                width: 16, // Width of the circle
                                height: 16, // Height of the circle
                                decoration: BoxDecoration(
                                  color: Color(0xff132F59), // Color of the circle
                                  shape: BoxShape.circle, // Makes the container a circle
                                ),
                              ) : Container(
                                padding: EdgeInsets.only(top: 10),
                                child: SvgPicture.asset(
                                  "assets/DirectionInstruction_locationPin.svg",
                                  height: 28,
                                ),
                              ),

                            ],
                          ),

                          SizedBox(width: !widget.IsMultiBuilding && widget.reverse?defaultSpace*2:widget.IsMultiBuilding && !widget.reverse?defaultSpace*1.5:defaultSpace,),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              !widget.IsMultiBuilding || widget.reverse? ExcludeSemantics(
                                child: Text(
                                  widget.EndName,
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff3f3f46),
                                    height: 24/18,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ) :
                              ExcludeSemantics(
                                child: Text(
                                  "Exiting ${widget.StartBuildingName}",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff3f3f46),
                                    height: 24/18,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),

                            ],
                          )

                        ],
                      ),
                      Row(
                        children: [
                          !widget.IsMultiBuilding && widget.reverse?Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                height:25,
                                width: defaultLineWidth,
                                color: Color(0xff132F59),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 0),
                                child: SvgPicture.asset(
                                  "assets/DirectionInstruction_locationPin.svg",
                                  height: 30,
                                ),
                              ),

                            ],
                          ):Container(),
                          SizedBox(width: !widget.IsMultiBuilding && widget.reverse?defaultSpace:defaultSpace*3,),

                          !widget.IsMultiBuilding? ExcludeSemantics(
                            child: Container(
                                padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xff4899EA),
                                ),
                                child: Text("Floor ${widget.EndFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.white))),
                          ) : widget.reverse? ExcludeSemantics(
                            child: Container(
                                padding: EdgeInsets.only(top:5,bottom: 5,left: 10,right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Color(0xffF9D2D3),
                                ),
                                child:Text("${widget.EndBuildingName} - Floor ${widget.StartFloor.toString()}", style: const TextStyle(fontSize: 14,color:Colors.black))),
                          ): Container(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getCustomIcon(String direction,context) {
    if (direction ==  LocaleData.gostraight.getString(context)) {
      return Icon(
        Icons.straight,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.slightright.getString(context))) {
      return Icon(
        Icons.turn_slight_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.sharpright.getString(context))) {
      return Icon(
        Icons.turn_sharp_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.tright.getString(context))) {
      return Icon(
        Icons.turn_right,
        color: Colors.black,
        size: 32,
      );
    }  else if (direction.contains(LocaleData.uturn.getString(context))) {
      return Icon(
        Icons.u_turn_right,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.sharpleft.getString(context))) {
      return Icon(
        Icons.turn_sharp_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains(LocaleData.slightleft.getString(context))) {
      return Icon(
        Icons.turn_slight_left,
        color: Colors.black,
        size: 32,
      );

    } else if (direction.contains(LocaleData.tleft.getString(context))) {
      return Icon(
        Icons.turn_left,
        color: Colors.black,
        size: 32,
      );
    } else if (direction.contains("Lift")) {
      return Padding(
        padding: const EdgeInsets.all(3.5),
        child: SvgPicture.asset("assets/elevator.svg"),
      );
    }
    // else if(direction.substring(0,4)=="Take"){
    //   return Icon(
    //     Icons.abc,
    //     color: Colors.black,
    //     size: 32,
    //   );
    // }

    else {
      return Icon(
        Icons.check_box_outline_blank,
        color: Colors.black,
        size: 32,
      );
    }
  }
}