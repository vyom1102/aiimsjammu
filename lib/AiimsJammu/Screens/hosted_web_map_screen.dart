import 'package:flutter/material.dart';
import 'package:iwayplus_scanner/iwayplus_scanner.dart';

/// Hosts the web map with native BLE and GPS supplied by the scanner bridge.
/// Closing this route stops the scanner streams.
class HostedWebMapScreen extends StatefulWidget {
  final String venueName;
  final String apiKey;
  final String? destinationLandmarkId;

  const HostedWebMapScreen({
    super.key,
    required this.venueName,
    required this.apiKey,
    this.destinationLandmarkId,
  });

  @override
  State<HostedWebMapScreen> createState() => _HostedWebMapScreenState();
}

class _HostedWebMapScreenState extends State<HostedWebMapScreen>
    with WidgetsBindingObserver {
  // `--dart-define=MAP_BASE_URL=http://<mac-ip>:<port>/` points the map at a
  // local web build for testing before it is deployed.
  static const String _mapBaseUrl = String.fromEnvironment('MAP_BASE_URL',
      defaultValue: 'https://maps.iwayplus.in/iwaymaps/');

  // Permissions are asked before the map is shown, otherwise scanning silently
  // produces no readings. Null while the request is still on screen. Denied
  // doesn't block the map: with a venue the page still draws it, and its own
  // relocalize prompt offers Open Settings.
  bool? _granted;

  String get _url => Uri.parse(_mapBaseUrl).replace(queryParameters: {
        'venueName': widget.venueName,
        'apiKey': widget.apiKey,
        if (widget.destinationLandmarkId != null)
          'destinationLandmarkId': widget.destinationLandmarkId!,
      }).toString();

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

  // Back from system settings: re-read the permissions without prompting.
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
      // swipe-back, or the page's own exit, which lands in onClose.
      body: SafeArea(
        child: _granted == null
            ? const Center(child: CircularProgressIndicator())
            : IwayplusNavigation(
                url: _url,
                autoRequestPermissions: false,
                onClose: () => Navigator.of(context).maybePop(),
              ),
      ),
    );
  }
}
