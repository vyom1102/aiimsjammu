import UIKit
import GoogleMaps
import flutter_local_notifications
import Flutter
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
    private let gpsChannelName = "gps_scan"
    private let bleChannelName = "ble_scanner"

    private var locationManager: CLLocationManager?
    private var gpsEventSink: FlutterEventSink?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Google Maps API Key
        GMSServices.provideAPIKey("AIzaSyA0U_ddvL7t0gRdteVw_9MpVER1N0oqfY8")

        // Flutter Local Notifications setup
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        let controller = window?.rootViewController as! FlutterViewController

        // Register GPS Streaming EventChannel
        let gpsChannel = FlutterEventChannel(name: gpsChannelName, binaryMessenger: controller.binaryMessenger)
        gpsChannel.setStreamHandler(GPSStreamHandler())

        // Register BLE Scanner MethodChannel
        let bleChannel = FlutterMethodChannel(name: bleChannelName, binaryMessenger: controller.binaryMessenger)
        let bleManager = BLEManager()

        bleChannel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "startScan":
                bleManager.startScan(result: result)
            case "stopScan":
                bleManager.stopScan()
                result("Scanning stopped.")
            case "initialLocalization":
                bleManager.initialLocalization(result: result)
            case "getBestDevice":
                bleManager.getBestDevice(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Register generated plugins
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

// MARK: - GPS Streaming Handler
class GPSStreamHandler: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        if CLLocationManager.locationServicesEnabled() {
        print("locationServices");
            let status = CLLocationManager.authorizationStatus()
            if status == .notDetermined {
                locationManager?.requestWhenInUseAuthorization()
            } else if status == .denied || status == .restricted {
                return FlutterError(code: "PERMISSION_DENIED", message: "Location permission is denied.", details: nil)
            }
        } else {
            return FlutterError(code: "LOCATION_DISABLED", message: "Location services are disabled.", details: nil)
        }

        locationManager?.startUpdatingLocation()
        return nil
    }


    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        eventSink = nil
        return nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy // Accuracy in meters
        ]

        eventSink?(locationData)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        eventSink?(FlutterError(code: "LOCATION_ERROR", message: error.localizedDescription, details: nil))
    }
}
