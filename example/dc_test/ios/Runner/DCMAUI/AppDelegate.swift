import UIKit
import Flutter

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "main engine")
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    flutterEngine.run(withEntrypoint: nil)
    GeneratedPluginRegistrant.register(with: flutterEngine)
    
    // Register native UI manager
    let registrar = flutterEngine.registrar(forPlugin: "com.dcmaui.framework")
    NativeUIManager.register(with: registrar!)
    
    // Create minimal window setup without Flutter UI
    self.window = UIWindow(frame: UIScreen.main.bounds)
    let rootVC = UIViewController()
    self.window.rootViewController = rootVC
    self.window.makeKeyAndVisible()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
}
