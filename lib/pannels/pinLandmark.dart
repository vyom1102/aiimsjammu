import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../APIMODELS/landmark.dart';

class pinLandmark extends StatefulWidget {
  final Function(MarkerId) update;
  final Function() localize;
  final Map<MarkerId, Marker> nearbyLandmarks;
  Landmarks? pinedLandmark;

  pinLandmark({
    required this.update,
    required this.nearbyLandmarks,
    required this.pinedLandmark,
    required this.localize,
    Key? key,
  }) : super(key: key);

  @override
  _pinLandmarkState createState() => _pinLandmarkState();
}

class _pinLandmarkState extends State<pinLandmark> {
  late FixedExtentScrollController _controller;
  int selectedindex = 0;

  @override
  void initState() {
    super.initState();
    if(widget.pinedLandmark != null){
      int index = widget.nearbyLandmarks.keys.toList().indexWhere((id)=>id.value==widget.pinedLandmark!.sId);
      _controller = FixedExtentScrollController(initialItem: index);
    }else{
      _controller = FixedExtentScrollController(initialItem: 0);
    }
  }

  Landmarks? _previousPinedLandmark;

  @override
  void didUpdateWidget(covariant pinLandmark oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if pinedLandmark has changed
    if (widget.pinedLandmark != oldWidget.pinedLandmark) {
      _previousPinedLandmark = oldWidget.pinedLandmark;
      _onPinedLandmarkChanged();
    }
  }

  void _onPinedLandmarkChanged() {
    if(widget.pinedLandmark != null){
      int index = widget.nearbyLandmarks.keys.toList().indexWhere((id)=>id.value==widget.pinedLandmark!.sId);
      if(selectedindex != index){
        selectedindex = index;
        setPickerIndex(selectedindex);
      }
    }
  }

  void setPickerIndex(int index) {
    // Dynamically change the selected index
    _controller.animateToItem(
      index,
      duration: Duration(milliseconds: 200), // Animation duration
      curve: Curves.easeInOut, // Animation curve
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Semantics(
          label: "Confirm Your Location Amongst Below Given List",
          readOnly: true,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ExcludeSemantics(
              child: Text(
                "Confirm Your Location",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff000000),
                  height: 24 / 18,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 2,
          width: screenWidth,
          color: Color(0xff24B9B0),
        ),
        SizedBox(height: 12,),
        Container(
          height: 100,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                // user swiped up
                if (selectedindex < widget.nearbyLandmarks.length - 1) {
                  selectedindex++;
                  _controller.animateToItem(selectedindex, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                  widget.update(widget.nearbyLandmarks.keys.toList()[selectedindex]);
                }
              } else if (details.primaryVelocity! > 0) {
                // user swiped down
                if (selectedindex > 0) {
                  selectedindex--;
                  _controller.animateToItem(selectedindex, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                  widget.update(widget.nearbyLandmarks.keys.toList()[selectedindex]);
                }
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Wheel ScrollView
                Expanded(
                  child: SizedBox(
                    height: 240, // Or 3 * itemExtent
                    child: ListWheelScrollView.useDelegate(
                      controller: _controller,
                      itemExtent: 80,
                      physics: const NeverScrollableScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final marker = widget.nearbyLandmarks.values.toList()[index];
                          final isSelected = index == selectedindex;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: isSelected
                                ? BoxDecoration(
                              border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
                            )
                                : null,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      marker.markerId.value.split('#')[1],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Near ${marker.markerId.value.split('#')[0]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: widget.nearbyLandmarks.length,
                      ),
                    ),
                  ),
                ),

                // Dot Indicator on the right
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.nearbyLandmarks.length, (index) {
                      bool isActive = index == selectedindex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        width: isActive ? 10 : 8,
                        height: isActive ? 10 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.teal : Colors.grey.withOpacity(0.4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        SizedBox(
          width: screenWidth,
          child: Container(
            margin: EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () {
                widget.localize();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Corner radius
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16), // Optional padding
              ),
              child: Text(
                "Confirm Location",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 24 / 18,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
