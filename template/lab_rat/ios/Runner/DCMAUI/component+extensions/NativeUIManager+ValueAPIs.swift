import UIKit

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func handleValueAPI(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getScreenWidth":
            result(UIScreen.main.bounds.width)
            
        case "getScreenHeight":
            result(UIScreen.main.bounds.height)
            
        case "getDeviceMetrics":
            let metrics: [String: Any] = [
                "width": UIScreen.main.bounds.width,
                "height": UIScreen.main.bounds.height,
                "scale": UIScreen.main.scale,
                "nativeScale": UIScreen.main.nativeScale,
                "pixelWidth": UIScreen.main.bounds.width * UIScreen.main.scale,
                "pixelHeight": UIScreen.main.bounds.height * UIScreen.main.scale,
                "aspectRatio": UIScreen.main.bounds.width / UIScreen.main.bounds.height,
                "isPortrait": UIScreen.main.bounds.height > UIScreen.main.bounds.width,
                "deviceModel": UIDevice.current.model,
                "deviceName": UIDevice.current.name,
                "systemName": UIDevice.current.systemName,
                "systemVersion": UIDevice.current.systemVersion,
                "isTablet": UIDevice.current.userInterfaceIdiom == .pad,
                "isPhone": UIDevice.current.userInterfaceIdiom == .phone,
                "hasNotch": hasNotch
            ]
            result(metrics)
            
        case "isDarkMode":
                result(UITraitCollection.current.userInterfaceStyle == .dark)
         
            
        case "getStatusBarHeight":
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                result(windowScene.statusBarManager?.statusBarFrame.height ?? 0)
            } else {
                result(UIApplication.shared.statusBarFrame.height)
            }
            
        case "getSafeAreaInset":
            guard let args = call.arguments as? [String: Any],
                  let edge = args["edge"] as? String,
                  let window = UIApplication.shared.windows.first else {
                result(0.0)
                return
            }
            
            let insets = window.safeAreaInsets
            switch edge {
            case "top": result(insets.top)
            case "bottom": result(insets.bottom)
            case "left": result(insets.left)
            case "right": result(insets.right)
            default: result(0.0)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private var hasNotch: Bool {
        guard let window = UIApplication.shared.windows.first else { return false }
        return window.safeAreaInsets.top >= 44
    }
}

// Add this to NativeUIManager's handle(_ call:result:) method
@available(iOS 13.0, *)
extension NativeUIManager {
    internal func addValueAPIMethodHandlers(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let valueAPIMethods: Set<String> = [
            "getScreenWidth",
            "getScreenHeight",
            "getDeviceMetrics",
            "isDarkMode",
            "getStatusBarHeight",
            "getSafeAreaInset"
        ]
        
        if valueAPIMethods.contains(call.method) {
            handleValueAPI(call, result: result)
        }
    }
}
