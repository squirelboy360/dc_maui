import UIKit
import Flutter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var flutterEngine: FlutterEngine?
    var nativeUIManager: NativeUIManager?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Create window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create root view controller
        let rootViewController = UIViewController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        // Initialize Flutter Engine
        flutterEngine = FlutterEngine(name: "io.flutter.engine")
        flutterEngine?.run(withEntrypoint: nil) // No UI entrypoint needed
        
        // Initialize NativeUIManager with the flutterEngine
        nativeUIManager = NativeUIManager(flutterEngine: flutterEngine)
        
        return true
    }
}

// Extension for UIColor to handle hex strings
extension UIColor {
    convenience init?(hexString: String) {
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
