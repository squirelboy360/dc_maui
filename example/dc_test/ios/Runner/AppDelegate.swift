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
        flutterEngine.run(withEntrypoint: nil, initialRoute: "/")
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        // Register our native UI manager with proper registrar
        let registrar = flutterEngine.registrar(forPlugin: "com.dcmaui.framework")
        NativeUIManager.register(with: registrar!)
        
        // Create Flutter view controller with our engine
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        // Configure window
        self.window.rootViewController = flutterViewController
        self.window.makeKeyAndVisible()
        
        // Allow headless execution
        flutterEngine.viewController = flutterViewController
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
