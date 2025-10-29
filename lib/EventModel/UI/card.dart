import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../ELEMENTS/HelperClass.dart';
import '../APIModel/CardData.dart';
import '../EventStatus.dart';
import 'package:intl/intl.dart';

class card extends StatelessWidget {
  final CardData data;
  bool openInDialoge;
  bool hideDirectionButton;
  PanelController? landmarkPannelController;
  card(this.data, {this.openInDialoge = false, this.hideDirectionButton = false, this.landmarkPannelController, super.key});

  List<Widget> getGenere() {
    List<Widget> widgets = [];
    // Display the categories in a capsule-like container
    if (data.categories != null && data.categories!.isNotEmpty) {
      widgets.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "${data.categories}",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 18 / 12,
            ),
          ),
        ),
      );
    }

    // Display up to two genres
    for (int i = 0; i < data.genre!.length && i < 2; i++) {
      // Get the genre string
      String genre = data.genre![i];

      // Split into words
      List<String> words = genre.split(" ");

      // Keep only first 3 words and add "..." if more
      String displayText =
      words.length > 3 ? words.take(3).join(" ") + "..." : genre;

      // Add comma only if multiple genres
      if (data.genre!.length > 1 && i < data.genre!.length - 1) {
        displayText += ",";
      }

      widgets.add(
        Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Text(
            "# $displayText",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xff010100),
              height: 18 / 12,
            ),
          ),
        ),
      );
    }


    // If there are more than 2 genres, show a "+x" indicator
    if (data.genre!.length > 2) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            "+${data.genre!.length - 2}",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xff010100),
              height: 18 / 12,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Color _getSubEventTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'workshop':
        return const Color(0xFF830C0E);
      case 'paper':
        return const Color(0xFF0C837F);
      case 'presentation':
        return const Color(0xFF9C27B0);
      case 'keynote':
        return const Color(0xFFFF6B35);
      case 'panel':
        return const Color(0xFF4CAF50);
      case 'invited talk':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xff2FC8AD);
    }
  }

  String formatTime(String? dateTimeStr) {
    if(dateTimeStr == null){
      return "-";
    }
    final inputFormat = DateFormat("yyyy-MM-ddTHH:mm");
    final outputFormat = DateFormat("h:mm a");
    final dt = inputFormat.parse(dateTimeStr);
    return outputFormat.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: (){
        if(data.sId != null){
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => EventDescriptionPage(eventId: data.sId!, fromNavigation: true,)),
          // ).then((value){
          //   print("landmarkPannelController ${landmarkPannelController} ${landmarkPannelController?.isAttached}");
          //   if(value == "collapse" && landmarkPannelController != null && landmarkPannelController!.isAttached){
          //     landmarkPannelController!.close();
          //   }
          // });
        }
      },
      child: data.eventName!.contains("Break")?
      Container(height: 121,
        width: screenWidth,
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: () {
            switch (getEventStatus(
              startDate: data.startDate!,
              endDate: data.endDate!,
              startTime: data.startTime!,
              endTime: data.endTime!,
              weekdays: data.weekDays
            )) {
              case EventStatus.goingOn:
                return const Color(0xffF1FFFE);
              case EventStatus.alreadyHappened:
                return Colors.grey.withOpacity(0.2);
              case EventStatus.goingToHappen:
                return Colors.white;
              case EventStatus.notToday:
                return Colors.grey.withOpacity(0.2);
            }
          }(),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.black12,
            width: 1.0,
          ),
        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/emoji_food_beverage.svg"),
          Text(
            "${data.eventName}",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xff000000),
              height: 20/16,
            ),
            textAlign: TextAlign.left,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.access_time_outlined, size: 16),
              SizedBox(width: 4),
              Text(
                "${formatTime(data.startTime)} - ${formatTime(data.endTime)}",
                style: const TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff010100),
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          Text(
            "${data.venueName}",
            style: const TextStyle(
              fontFamily: "Roboto",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff282828),
              height: 20/14,
            ),
            textAlign: TextAlign.left,
          )
        ],
      ),
      )
          :
      Container(
        height: 125,
        width: screenWidth,
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: () {
            switch (getEventStatus(
              startDate: data.startDate!,
              endDate: data.endDate!,
              startTime: data.startTime!,
              endTime: data.endTime!,
              weekdays: data.weekDays
            )) {
              case EventStatus.goingOn:
                return _getSubEventTypeColor(data.categories??"").withOpacity(0.1);
              case EventStatus.alreadyHappened:
                return Colors.grey.withOpacity(0.2);
              case EventStatus.goingToHappen:
                return Colors.white;
              case EventStatus.notToday:
                return Colors.white;
            }
          }(),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.black12,
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Align top
          children: [
            // Left colored strip
            Container(
              width: 10,
              height: double.infinity, // Makes the strip stretch to the content height
              decoration: BoxDecoration(
                color: _getSubEventTypeColor(data.categories??""),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),

            // Event details
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories and Genres
                    Row(
                      children: getGenere(),
                    ),
                    SizedBox(height: 8),

                    // Event name with ellipsis if it's too long
                    Flexible(
                      child: Text(
                        "${HelperClass.truncateString(data.eventName!, 40)}", // Limit to 40 characters
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff000000),
                          height: 23 / 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),

                   (data.speakerName != null && data.speakerName!.isNotEmpty)?Container(
                      margin: EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 16),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (data.speakerName ?? []).map((s) => s).join(", "),
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff010100),
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ):Container(),

                    // Time and location
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "${formatTime(data.startTime)} - ${formatTime(data.endTime)}",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff010100),
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 4),
                    //
                    // // Location
                    // {data.venueName ?? ""}.isEmpty?Container():Row(
                    //   children: [
                    //     Flexible(
                    //       child: Text(
                    //         "#${data.categories}",
                    //         style: const TextStyle(
                    //           fontFamily: "Roboto",
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w400,
                    //           color: Color(0xff010100),
                    //           height: 20 / 14,
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
