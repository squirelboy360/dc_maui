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
        let bridge = DCMauiNativeBridge.shared
        
        // Register Swift implementations with C layer
        
        dcmaui_register_swift_functions(
            { return bridge.dcmaui_initialize() },
            { viewId, type, props in return bridge.dcmaui_create_view(viewId, type, props) },
            { viewId, props in return bridge.dcmaui_update_view(viewId, props) },
            { viewId in return bridge.dcmaui_delete_view(viewId) },
            { childId, parentId, index in return bridge.dcmaui_attach_view(childId, parentId, index) },
            { viewId, children in return bridge.dcmaui_set_children(viewId, children) },
            { viewId, events in return bridge.dcmaui_add_event_listeners(viewId, events) },
            { viewId, events in return bridge.dcmaui_remove_event_listeners(viewId, events) }
        )
        
        // Register a root container view for our UI
        if let rootView = rootView as UIView? {
            let rootContainer = UIView(frame: rootView.bounds)
            rootContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            rootContainer.backgroundColor = .clear
            rootContainer.tag = 1001
            rootView.addSubview(rootContainer)
            
            // Store this view in the registry with a known ID
            bridge.dcmaui_create_view(
                strdup("root"),
                strdup("View"),
                strdup("{\"backgroundColor\":\"#FFFFFF\"}")
            )
        }
        
        print("DC MAUI: Native bridge initialized")
    }
}
