// Inside AppDelegate.swift or the relevant entry point for iOS
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Ensure the method channel is registered correctly
    NativeUIManager.register(with: self.registrar(forPlugin: "com.dcmaui.framework")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
