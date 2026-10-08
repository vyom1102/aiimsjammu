import 'package:flutter/material.dart';
import 'package:iwayplus_scanner/iwayplus_scanner.dart';

import '../config.dart';

/// Hosted Iwayplus web map (NavigationSDK Integration Guide §7.1).
///
/// Showing this screen opens the map; popping it closes the map and stops
/// all BLE/GPS scanning.
class VenueMapScreen extends StatefulWidget {
  final String venueName;
  final String? destinationLandmarkId;
  final List<String>? buildingIDs;

  const VenueMapScreen({
    super.key,
    this.venueName = AppConfig.venueName,
    this.destinationLandmarkId,
    this.buildingIDs
  });

  @override
  State<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends State<VenueMapScreen>
    with WidgetsBindingObserver {
  // `--dart-define=MAP_BASE_URL=http://localhost:5460/` points the map at a
  // local build for testing before it is deployed.
  static const String _mapBaseUrl = String.fromEnvironment('MAP_BASE_URL',
      defaultValue: 'https://maps.iwayplus.in/iwaymaps/');

  // Permissions are asked before the map is shown, otherwise scanning silently
  // produces no readings. Null while the request is still on screen.
  bool? _granted;

  String get _url => Uri.parse(_mapBaseUrl).replace(queryParameters: {
        'venueName': widget.venueName,
        'apiKey':'98f13750-c905-11f0-b802-d78f56bdcf4f',
        if (widget.destinationLandmarkId != null)
          'destinationLandmarkId': widget.destinationLandmarkId!,
        if(widget.buildingIDs != null && widget.buildingIDs!.isNotEmpty)
          'buildingIds': widget.buildingIDs!,
      }).toString();

  // With a venue the page can still draw the map without positioning, and its
  // own relocalize prompt offers Open Settings — so denied permissions don't
  // block it. Without one there is nothing to show.
  bool get _hasVenue =>
      Uri.parse(_url).queryParameters['venueName']?.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestScannerPermissions().then((granted) {
      if (mounted) setState(() => _granted = granted);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from system settings: re-read the permissions without prompting, and
  // open the map if they were granted there.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _granted != false) return;
    IwayplusScanner.getState().then((adapter) {
      if (mounted && adapter.bluetoothPermission && adapter.locationPermission) {
        setState(() => _granted = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar: the map is closed with the system back button / iOS
      // swipe-back, since the hosted page's own exit action doesn't fire onClose.
      body: SafeArea(
        child: switch (_granted) {
          null => const Center(child: CircularProgressIndicator()),
          false when !_hasVenue => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Indoor positioning needs Bluetooth and location permissions.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Same action as the page's relocalize "Open Settings".
                    ElevatedButton(
                      onPressed: IwayplusScanner.openSettings,
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              ),
            ),
          _ => IwayplusNavigation(
              url: _url,
              autoRequestPermissions: false,
              // The page's exit (e.g. the feedback panel's Done/Exit) calls
              // window.__iwayplusScanner.close(), which lands here.
              onClose: () => Navigator.of(context).maybePop(),
            ),
        },
      ),
    );
  }
}
