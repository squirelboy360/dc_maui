import UIKit
import Flutter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var flutterEngine: FlutterEngine?
    var nativeUIManager: NativeUIManager?
    
    @nonobjc func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Create window and set up root view controller first
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .white
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        // Initialize Flutter engine for headless execution
        flutterEngine = FlutterEngine(name: "io.flutter.engine")
        
        // Register plugins before running the engine
        self.registerPlugins()
        
        // Run engine without any UI entrypoint
        guard let flutterEngine = flutterEngine,
              flutterEngine.run(withEntrypoint: nil) else {
            fatalError("Failed to run Flutter engine")
        }
        
        // Initialize and register NativeUIManager after engine is running
        nativeUIManager = NativeUIManager(flutterEngine: flutterEngine)
        
        return true
    }
    
    private func registerPlugins() {
        guard let flutterEngine = flutterEngine else { return }
        GeneratedPluginRegistrant.register(with: flutterEngine)
    }
}

// Plugin registration
private class RegisterGeneratedPlugins: NSObject {
    static func register(with registry: FlutterPluginRegistry) {
        if let registrar = registry.registrar(forPlugin: "NativeUIManager") {
            let channel = FlutterMethodChannel(
                name: "com.dcmaui.framework",
                binaryMessenger: registrar.messenger()
            )
            let instance = NativeUIManager(flutterEngine: registry as? FlutterEngine)
            channel.setMethodCallHandler(instance.handle(_:result:))
        }
    }
}


extension UIColor {
    convenience init?(named hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}
