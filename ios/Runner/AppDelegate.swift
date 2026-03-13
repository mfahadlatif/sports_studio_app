import Flutter
import UIKit
import GoogleMaps
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase once if present
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // Provide Google Maps API key from Info.plist (key: GMSApiKey); fallback to provided key
    let infoPlistKey = (Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    let fallbackKey = "AIzaSyA_XxF4bHfDdpRtUSjXyHWSQAfJIYoQCUA"
    let mapsKeyToUse = (infoPlistKey?.isEmpty == false) ? infoPlistKey! : fallbackKey
    GMSServices.provideAPIKey(mapsKeyToUse)
    if infoPlistKey == nil || infoPlistKey?.isEmpty == true {
      NSLog("Info: Using fallback Google Maps API key; consider adding GMSApiKey to Info.plist.")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
