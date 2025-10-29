import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwaymaps/pannels/pinLandmarkCampus.dart';
import 'package:iwaymaps/pannels/pinLandmarkIndoor.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../APIMODELS/landmark.dart';

class pinLandmarkPannel {
  final PanelController _panelController = PanelController();
  FocusNode focusNode = FocusNode();

  // Method to show the panel
  void showPanel() {
    _panelController.open();
    focusNode.requestFocus();
  }

  // Method to hide the panel
  void hidePanel() {
    _panelController.close();
  }

  bool isPanelOpened(){
    try {
      return _panelController.isPanelOpen;
    }catch(e){
      return false;
    }
  }

  // Method to toggle panel visibility
  void togglePanel() {
    if (_panelController.isPanelOpen) {
      hidePanel();
    } else {
      showPanel();
    }
  }

  bool isTalkBackOn() {
    return SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;
  }

  // Method to get the SlidingUpPanel widget
  Widget getPanelWidget(
      BuildContext context,
      Function(MarkerId) update,
      Function() localize,
      Function() closePanel,
      Map<MarkerId, Marker> nearbyLandmarks,
      Landmarks? pinedLandmark,
      ) {
    return Semantics(
      excludeSemantics: !(_panelController.isAttached && _panelController.isPanelOpen),
      child: Stack(
        children: [
          Visibility(
            // visible: isPanelOpened(),
            visible: false,
            child: Positioned(
              left: 10,
              top: 24,
              child: ElevatedButton(
                onPressed: localize,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  elevation: 5,
                  backgroundColor: const Color(0xff24B9B0),
                  foregroundColor: Colors.white,
                ),
                child: Semantics(
                  label: "Back",
                  child: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Panel with autofocus
          Focus(
            autofocus: true, // 👈 ensures TalkBack starts here
            child: SlidingUpPanel(
              controller: _panelController,
              panel: isTalkBackOn()
                  ? pinLandmarkIndoor(
                update: update,
                nearbyLandmarks: nearbyLandmarks,
                pinedLandmark: pinedLandmark,
                localize: localize,
                focusNode: focusNode
              )
                  : pinLandmarkCampus(
                update: update,
                nearbyLandmarks: nearbyLandmarks,
                pinedLandmark: pinedLandmark,
                localize: localize,
              ),
              minHeight: 0,
              maxHeight: 240,
              backdropOpacity: 0.5,
              isDraggable: false,
            ),
          ),
        ],
      ),
    );
  }

}
