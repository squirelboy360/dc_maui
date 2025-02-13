import UIKit
import Flutter

@available(iOS 13.0, *)
class NativeNavigationController: UINavigationController {
    var onPop: ((String) -> Void)?
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let popped = super.popViewController(animated: animated)
        if let viewController = popped as? NativeViewController {
            onPop?(viewController.screenId)
        }
        return popped
    }
}

@available(iOS 13.0, *)
class NativeViewController: UIViewController {
    let screenId: String
    let rootView: UIView
    
    init(screenId: String, rootView: UIView) {
        self.screenId = screenId
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(rootView)
        rootView.frame = view.bounds
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

@available(iOS 13.0, *)
class NativeTabBarController: UITabBarController {
    var screenIds: [String] = []
}

@available(iOS 13.0, *)
extension NativeUIManager {
      private var tabController: NativeTabBarController? {
        window?.rootViewController as? NativeTabBarController
    }
    
    // Setup Methods
    func setupNavigationController() {
        let navController = NativeNavigationController()
        navController.onPop = { [weak self] screenId in
            self?.handleScreenPop(screenId)
        }
        window?.rootViewController = navController
    }
    private func handleSetupNavigation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Set up initial navigation controller if not already done
        if navigationController == nil {
            setupNavigationController()
        }
        result(true)
    }
    
    func handleNavigationSetup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setupNavigation":
            handleSetupNavigation(call, result: result)
            
        case "setupTabs":
            guard let args = call.arguments as? [String: Any],
                  let tabs = args["tabs"] as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid tab configuration", details: nil))
                return
            }
            setupTabController(tabs: tabs)
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func setupTabController(tabs: [[String: Any]]) {
        let tabController = NativeTabBarController()
        let viewControllers = tabs.compactMap { tabInfo -> UIViewController? in
            guard let screenId = tabInfo["screenId"] as? String,
                  let title = tabInfo["title"] as? String,
                  let view = createTabView(screenId: screenId) else {
                return nil
            }
            
            let vc = NativeViewController(screenId: screenId, rootView: view)
            vc.title = title
            return vc
        }
        
        tabController.viewControllers = viewControllers
        tabController.screenIds = tabs.compactMap { $0["screenId"] as? String }
        window?.rootViewController = tabController
    }
    
    // Navigation Methods
    func pushScreen(_ screenId: String, animated: Bool = true) {
        guard let view = createScreenView(screenId: screenId) else { return }
        let viewController = NativeViewController(screenId: screenId, rootView: view)
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func popScreen(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func presentModal(_ screenId: String, animated: Bool = true) {
        guard let view = createScreenView(screenId: screenId) else { return }
        let viewController = NativeViewController(screenId: screenId, rootView: view)
        navigationController?.present(viewController, animated: animated)
    }
    
    func dismissModal(animated: Bool = true) {
        navigationController?.dismiss(animated: animated)
    }
    
    func switchTab(_ index: Int) {
        tabController?.selectedIndex = index
    }
    
    // Helper Methods
    private func createScreenView(screenId: String) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        // Store view reference
        views[screenId] = view
        childViews[screenId] = []
        return view
    }
    
    private func createTabView(screenId: String) -> UIView? {
        createScreenView(screenId: screenId)
    }
    
    private func handleScreenPop(_ screenId: String) {
        // Notify Flutter about screen pop
        let eventData: [String: Any] = [
            "type": "navigation",
            "event": "pop",
            "screenId": screenId
        ]
        methodChannel?.invokeMethod("onNativeEvent", arguments: eventData)
    }
    
    // Handle navigation method calls from Flutter
    func handleNavigationMethod(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "pushScreen":
            guard let args = call.arguments as? [String: Any],
                  let screenId = args["screenId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing screenId", details: nil))
                return
            }
            pushScreen(screenId, animated: args["animated"] as? Bool ?? true)
            result(true)
            
        case "popScreen":
            popScreen(animated: call.arguments as? Bool ?? true)
            result(true)
            
        case "presentModal":
            guard let args = call.arguments as? [String: Any],
                  let screenId = args["screenId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing screenId", details: nil))
                return
            }
            presentModal(screenId, animated: args["animated"] as? Bool ?? true)
            result(true)
            
        case "dismissModal":
            dismissModal(animated: call.arguments as? Bool ?? true)
            result(true)
            
        case "setupTabs":
            guard let args = call.arguments as? [String: Any],
                  let tabs = args["tabs"] as? [[String: Any]] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid tabs configuration", details: nil))
                return
            }
            setupTabController(tabs: tabs)
            result(true)
            
        case "switchTab":
            guard let args = call.arguments as? [String: Any],
                  let index = args["index"] as? Int else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing tab index", details: nil))
                return
            }
            switchTab(index)
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
