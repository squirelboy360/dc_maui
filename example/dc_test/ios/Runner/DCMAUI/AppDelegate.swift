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
        // Initialize and run the Flutter engine
        flutterEngine.run(withEntrypoint: nil)
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        // Register native UI manager
        let registrar = flutterEngine.registrar(forPlugin: "com.dcmaui.framework")
        NativeUIManager.register(with: registrar!)
        
        // Set up window with Flutter view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
            window.rootViewController = flutterViewController
            self.window = window
            window.makeKeyAndVisible()
            
            // Allow headless execution
            flutterEngine.viewController = flutterViewController
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
