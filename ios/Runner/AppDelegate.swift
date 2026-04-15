import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let appChannel = FlutterMethodChannel(name: "com.mindq/app", binaryMessenger: controller.binaryMessenger)
      appChannel.setMethodCallHandler { (call, result) in
        if call.method == "moveToBackground" {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIApplication.shared.perform(NSSelectorFromString("suspend"))
          }
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return result
  }
}
