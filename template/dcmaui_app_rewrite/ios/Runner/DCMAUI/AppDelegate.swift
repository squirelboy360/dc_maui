import UIKit
import Flutter

// Global C-compatible bridge functions with proper nullability
@_cdecl("swift_initialize")
func swift_initialize() -> Int8 {
    return DCMauiNativeBridge.shared.dcmaui_initialize()
}

@_cdecl("swift_create_view")
func swift_create_view(_ viewId: UnsafePointer<CChar>?, _ type: UnsafePointer<CChar>?, _ props: UnsafePointer<CChar>?) -> Int8 {
    guard let viewId = viewId, let type = type, let props = props else {
        return 0 // Fail if any parameter is nil
    }
    return DCMauiNativeBridge.shared.dcmaui_create_view(viewId, type, props)
}

@_cdecl("swift_update_view")
func swift_update_view(_ viewId: UnsafePointer<CChar>?, _ props: UnsafePointer<CChar>?) -> Int8 {
    guard let viewId = viewId, let props = props else {
        return 0
    }
    return DCMauiNativeBridge.shared.dcmaui_update_view(viewId, props)
}

@_cdecl("swift_delete_view")
func swift_delete_view(_ viewId: UnsafePointer<CChar>?) -> Int8 {
    guard let viewId = viewId else {
        return 0
    }
    return DCMauiNativeBridge.shared.dcmaui_delete_view(viewId)
}

@_cdecl("swift_attach_view")
func swift_attach_view(_ childId: UnsafePointer<CChar>?, _ parentId: UnsafePointer<CChar>?, _ index: Int32) -> Int8 {
    guard let childId = childId, let parentId = parentId else {
        return 0
    }
    return DCMauiNativeBridge.shared.dcmaui_attach_view(childId, parentId, index)
}

@_cdecl("swift_set_children")
func swift_set_children(_ viewId: UnsafePointer<CChar>?, _ children: UnsafePointer<CChar>?) -> Int8 {
    guard let viewId = viewId, let children = children else {
        return 0
    }
    return DCMauiNativeBridge.shared.dcmaui_set_children(viewId, children)
}

@_cdecl("swift_add_event_listeners")
func swift_add_event_listeners(_ viewId: UnsafePointer<CChar>?, _ events: UnsafePointer<CChar>?) -> Int8 {
    guard let viewId = viewId, let events = events else {
        return 0
    }
    return DCMauiNativeBridge.shared.dcmaui_add_event_listeners(viewId, events)
}

@_cdecl("swift_remove_event_listeners")
func swift_remove_event_listeners(_ viewId: UnsafePointer<CChar>?, _ events: UnsafePointer<CChar>?) -> Int8 {
    guard let viewId = viewId, let events = events else {
        return 0
    }
    return DCMauiNativeBridge.shared.dcmaui_remove_event_listeners(viewId, events)
}

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
        
        // Create window with proper frame
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create a native container view controller with explicit background
        let nativeRootVC = UIViewController()
        nativeRootVC.view.backgroundColor = .white
        nativeRootVC.title = "DC MAUI Native UI"
        
        // Initialize and setup DCMauiNativeBridge
        setupDCMauiNativeBridge(rootView: nativeRootVC.view)
        
        // Use the native view controller as root
        self.window.rootViewController = nativeRootVC
        self.window.makeKeyAndVisible()

        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterEngine.viewController = flutterViewController
        
        print("DC MAUI: Running in headless mode with native UI container")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Setup the DCMauiNativeBridge and register Swift implementations with the C layer
    private func setupDCMauiNativeBridge(rootView: UIView) {
        // Register Swift functions with C bridge - using function pointers to global C-compatible functions
        dcmaui_register_swift_functions(
            swift_initialize,
            swift_create_view,
            swift_update_view,
            swift_delete_view,
            swift_attach_view,
            swift_set_children,
            swift_add_event_listeners,
            swift_remove_event_listeners
        )
        
        // Set up the root container view
        if let rootView = rootView as UIView? {
            let rootContainer = UIView(frame: rootView.bounds)
            rootContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            rootContainer.backgroundColor = .clear
            rootContainer.tag = 1001
            rootView.addSubview(rootContainer)
            
            // Register the root view with a known ID
            let rootId = "root".cString(using: .utf8)!
            let type = "View".cString(using: .utf8)!
            let props = "{\"backgroundColor\":\"#FFFFFF\"}".cString(using: .utf8)!
            
            // Use direct call to the Swift bridge function
            DCMauiNativeBridge.shared.manuallyCreateRootView(rootContainer, viewId: "root", props: ["backgroundColor": "#FFFFFF"])
            
            print("DC MAUI: Root view registered with ID: root")
        }
        
        print("DC MAUI: Native bridge initialized")
    }
}
