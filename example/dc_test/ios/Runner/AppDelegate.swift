import UIKit
import Flutter

@main
class AppDelegate: UIResponder, UIApplicationDelegate, FlutterPlugin {
    var window: UIWindow?
    var flutterEngine: FlutterEngine?
    var nativeUIManager: NativeUIManager?
    
    @nonobjc func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Flutter engine
        flutterEngine = FlutterEngine(name: "io.flutter.engine")
        
        // Register plugins BEFORE running the engine
        self.registerPlugins()
        
        // Create window and set up root view controller
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .blue
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        // Run engine
        guard let flutterEngine = flutterEngine,
              flutterEngine.run() else {
            fatalError("Failed to run Flutter engine")
        }
        
        // Initialize NativeUIManager
        nativeUIManager = NativeUIManager(flutterEngine: flutterEngine)
        
        return true
    }
    
    func registerPlugins() {
        guard let registrar = flutterEngine?.registrar(forPlugin: "NativeUIManager") else { return }
        
        // Register the plugin
        AppDelegate.register(with: registrar)
    }
    
    // MARK: - FlutterPlugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.dcmaui.framework",
            binaryMessenger: registrar.messenger()
        )
        let instance = NativeUIManager(flutterEngine: registrar.messenger() as? FlutterEngine)
        channel.setMethodCallHandler(instance?.handle(_:result:))
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
