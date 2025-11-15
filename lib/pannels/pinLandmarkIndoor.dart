import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../APIMODELS/landmark.dart';

class pinLandmarkIndoor extends StatefulWidget {
  final Function(MarkerId) update;
  final Function() localize;
  final Map<MarkerId, Marker> nearbyLandmarks;
  Landmarks? pinedLandmark;
  FocusNode focusNode;

  pinLandmarkIndoor({
    required this.update,
    required this.nearbyLandmarks,
    required this.pinedLandmark,
    required this.localize,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  _pinLandmarkIndoorState createState() => _pinLandmarkIndoorState();
}

class _pinLandmarkIndoorState extends State<pinLandmarkIndoor> {
  late FixedExtentScrollController _controller;
  int selectedindex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.pinedLandmark != null) {
      int index = widget.nearbyLandmarks.keys
          .toList()
          .indexWhere((id) => id.value == widget.pinedLandmark!.sId);
      _controller = FixedExtentScrollController(initialItem: index);
    } else {
      _controller = FixedExtentScrollController(initialItem: 0);
    }
  }

  Landmarks? _previousPinedLandmark;

  @override
  void didUpdateWidget(covariant pinLandmarkIndoor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if pinedLandmark has changed
    if (widget.pinedLandmark != oldWidget.pinedLandmark) {
      _previousPinedLandmark = oldWidget.pinedLandmark;
      _onPinedLandmarkChanged();
    }
  }

  void _onPinedLandmarkChanged() {
    if (widget.pinedLandmark != null) {
      int index = widget.nearbyLandmarks.keys
          .toList()
          .indexWhere((id) => id.value == widget.pinedLandmark!.sId);
      if (selectedindex != index) {
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
        SizedBox(
          height: 12,
        ),
        Container(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            itemCount: widget.nearbyLandmarks.length,
            itemBuilder: (context, index) {
              final marker = widget.nearbyLandmarks.values.toList()[index];
              final isSelected = index == selectedindex;

              String label = marker.markerId.value.split('#')[1].isEmpty
                  ? marker.markerId.value.split('#')[0]
                  : "${marker.markerId.value.split('#')[1]}, Near ${marker.markerId.value.split('#')[0]}";

              return Semantics(
                label:
                    "$label, item ${index + 1} of ${widget.nearbyLandmarks.length}",
                button: true,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedindex = index;
                    });
                    await widget.update(widget.nearbyLandmarks.keys.toList()[index]);
                    widget.localize();
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: marker.markerId.value.split('#')[1].isEmpty
                            ? [
                                Text(
                                  marker.markerId.value.split('#')[0],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ]
                            : [
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
                ),
              );
            },
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
