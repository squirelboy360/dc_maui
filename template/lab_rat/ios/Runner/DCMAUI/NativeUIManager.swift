import UIKit
import Flutter
import yoga  

@available(iOS 13.0, *)
class NativeUIManager: NSObject, FlutterPlugin {
    // Properties
    internal var methodChannel: FlutterMethodChannel?
    internal var views: [String: UIView] = [:]
    internal var childViews: [String: [String]] = [:]
    private var rootViewId: String?
    internal var window: UIWindow?
    internal var layoutConfigs: [String: LayoutConfig] = [:]
    internal var yogaNodes: [String: YGNodeRef] = [:]
    internal var registeredGestureRecognizers: [String: [UIGestureRecognizer]] = [:] // Move to internal
    
    // unified handler
    internal var eventHandlers: [String: [EventType: (EventData) -> Void]] = [:]

    // Make getViewId internal so extensions can access it
    internal func getViewId(for view: UIView) -> String? {
        return views.first(where: { $0.value == view })?.key
    }
    
    // Add setupRootView back
    internal func setupRootView() {
        print("Setting up root view")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            window = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window?.windowScene = windowScene
            
            let rootVC = UIViewController()
            
            // Create root view with proper Yoga configuration
            let rootView = UIView(frame: rootVC.view.bounds)
            rootView.backgroundColor = .white
            rootView.yoga.isEnabled = true
            rootView.yoga.flexDirection = .column
            
            // Important: Set absolute dimensions
            rootView.yoga.width = YGValue(value: Float(UIScreen.main.bounds.width), unit: .point)
            rootView.yoga.height = YGValue(value: Float(UIScreen.main.bounds.height), unit: .point)
            rootView.yoga.alignItems = .stretch // Make children stretch by default
            
            rootVC.view.addSubview(rootView)
            rootView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add constraints to ensure root view fills screen
            NSLayoutConstraint.activate([
                rootView.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
                rootView.leftAnchor.constraint(equalTo: rootVC.view.leftAnchor),
                rootView.rightAnchor.constraint(equalTo: rootVC.view.rightAnchor),
                rootView.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor)
            ])
            
            rootViewId = "root-\(UUID().uuidString)"
            views[rootViewId!] = rootView
            childViews[rootViewId!] = []
            
            window?.rootViewController = rootVC
            window?.makeKeyAndVisible()
        }
    }
    
    // Required FlutterPlugin method
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeUIManager()
        let channel = FlutterMethodChannel(
            name: "com.dcmaui.framework",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.methodChannel = channel
        
        // Initialize after a brief delay to ensure Flutter is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            instance.setupRootView()
        }
    }
    
    // Required FlutterPlugin method
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch call.method {
            case "createView":
                self.handleCreateView(call, result: result)
            case "attachView":
                self.handleAttachView(call, result: result)
            case "deleteView":
                self.handleDeleteView(call, result: result)
            case "clearAllViews":
                self.handleDeleteAllViews(call, result: result)
            case "updateView":
                self.handleUpdateView(call, result: result)
            case "setViewProperties":
                self.handleSetViewProperties(call, result: result)
            case "addChildView":
                self.handleAddChildView(call, result: result)
            case "removeChildView":
                self.handleRemoveChildView(call, result: result)
            case "getViewById":
                self.handleGetViewById(call, result: result)
            case "getChildren":
                self.handleGetChildren(call, result: result)
            case "changeViewBackgroundColor":
                self.handleChangeViewBackgroundColor(call, result: result)
            case "setViewVisibility":
                self.handleSetViewVisibility(call, result: result)
            case "getRootView":
                self.handleGetRootView(result: result)
            case "setViewLayout":
                self.handleSetViewLayout(call, result: result)
            case "applyLayout":
                self.applyLayout(call, result: result)
            case "registerEvent":
                self.handleRegisterEvent(call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // Required FlutterPlugin method
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        methodChannel = nil
        cleanup()
    }
    
    // Add new method to handle event registration
    private func handleRegisterEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventTypeString = args["eventType"] as? String,
              let view = views[viewId],
              let eventType = EventType(rawValue: eventTypeString) else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid event registration arguments", details: nil))
            return
        }
        
        registerEvent(viewId, type: eventType)
        result(true)
    }

    private func handleCreateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewType = args["viewType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing viewType", details: nil))
            return
        }

        let properties = args["properties"] as? [String: Any] ?? [:]
        print("Creating \(viewType) with properties: \(properties)") // Debug log

        let view: UIView?
        let viewId = "\(viewType.lowercased())-\(UUID().uuidString)"

        switch viewType {
        case "Button":
            let button = UIButton(type: .system)
            
            // Set default appearance
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
            button.layer.cornerRadius = 28
            
            // Force layout mode that preserves text
            button.contentHorizontalAlignment = .center
            button.contentVerticalAlignment = .center
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.5
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            
            // Apply layout first
            if let layout = args["layout"] as? [String: Any] {
                let config = LayoutConfig(from: layout)
                applyYogaLayout(to: button, config: config)
            }
            
            // Apply styles after events and layout
            if let style = properties["textStyle"] as? [String: Any] {
                if let text = style["text"] as? String {
                    button.setTitle(text, for: .normal)
                    print("Setting button text to: \(text)")
                }
                if let color = style["color"] as? UInt32 {
                    button.setTitleColor(UIColor(rgb: color), for: .normal)
                }
                if let fontSize = style["fontSize"] as? CGFloat {
                    button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .bold)
                }
            }
            
            let style = NativeViewStyle(from: properties)
            style.apply(to: button)
            
            // Add default text color if none specified
            button.setTitleColor(.black, for: .normal)
            
            view = button
            print("Button creation complete with ID: \(viewId)")

        case "View":
            let containerView = UIView(frame: .zero)
            containerView.backgroundColor = .clear
            view = containerView
            
        case "Label":
            let label = UILabel()
            // Add better text handling and debugging
            if let properties = args["properties"] as? [String: Any],
               let textStyle = properties["textStyle"] as? [String: Any],
               let text = textStyle["text"] as? String {
                print("Setting label text: \(text)")  // Debug log
                label.text = text
            }
            label.textAlignment = .center
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.textColor = .black  // Add default text color
            view = label
            
        case "TouchableOpacity":
            let touchable = createTouchableView()
            touchable.alpha = 1.0
            touchable.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
            touchable.addTarget(self, action: #selector(handleTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            view = touchable

        case "Scrollable", "ListView":
            // Use unified scrollable implementation
            view = createScrollableBase(viewType: viewType, args: args)

        default:
            view = UIView()
        }
        
        view?.translatesAutoresizingMaskIntoConstraints = false
        
        if let view = view {
            views[viewId] = view
            childViews[viewId] = []
            
            // Important: Apply styles before layout
            if let properties = args["properties"] as? [String: Any] {
                let style = NativeViewStyle(from: properties)
                style.apply(to: view)
            }
            
            // Apply layout with proper parent bounds
            if let layout = args["layout"] as? [String: Any] {
                let config = LayoutConfig(from: layout)
                if let superview = view.superview {
                    view.frame = CGRect(origin: .zero, size: superview.bounds.size)
                } else {
                    view.frame = UIScreen.main.bounds
                }
                applyYogaLayout(to: view, config: config)
            }
            
            result(viewId)
        } else {
            result(FlutterError(code: "CREATION_FAILED", message: "Failed to create view", details: nil))
        }
    }

    private func applyLayout(to view: UIView, layout: [String: Any]) {
        if let width = layout["width"] as? Double {
            view.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
        }
        
        if let height = layout["height"] as? Double {
            view.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
        }
        
        if let flex = layout["flex"] as? Double {
            view.setContentHuggingPriority(.init(rawValue: 1000 - Float(flex)), for: .horizontal)
            view.setContentHuggingPriority(.init(rawValue: 1000 - Float(flex)), for: .vertical)
        }
    }

    private func handleAttachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Attaching view with arguments: \(String(describing: call.arguments))")
        
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String,
              let parentView = views[parentId],
              let childView = views[childId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid parent or child ID", details: nil))
            return
        }
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.yoga.isEnabled = true // Enable yoga on child
        parentView.addSubview(childView)
        childViews[parentId]?.append(childId)
        
        // Trigger layout calculation
        parentView.yoga.applyLayout(preservingOrigin: false)
        
        result(true)
    }

    private func handleDeleteView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid view ID", details: nil))
            return
        }
        
        view.removeFromSuperview()
        views.removeValue(forKey: viewId)
        childViews.removeValue(forKey: viewId)
        registeredGestureRecognizers.removeValue(forKey: viewId)
        
        for (parentId, children) in childViews {
            if children.contains(viewId) {
                childViews[parentId]?.removeAll { $0 == viewId }
            }
        }
        
        result(true)
    }
    
    
    private func handleDeleteAllViews(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        clear all but first
        var rootTemp:[String: UIView] = [:];
        rootTemp.updateValue(views.first!.value, forKey: views.first!.key)
        views.removeAll();
        views = rootTemp;
        
        result(true)
    }

    private func handleUpdateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let properties = args["properties"] as? [String: Any],
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        print("Applying properties to view: \(properties)")  // Debug log
        
        // Handle text specifically for Label and Button
        if let textStyle = properties["textStyle"] as? [String: Any] {
            if let text = textStyle["text"] as? String {
                if let label = view as? UILabel {
                    label.text = text
                } else if let button = view as? UIButton {
                    button.setTitle(text, for: .normal)
                }
            }
        }
        
        let style = NativeViewStyle(from: properties)
        style.apply(to: view)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        result(true)
    }

    private func handleSetViewProperties(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        handleUpdateView(call, result: result)
    }

    private func handleAddChildView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        handleAttachView(call, result: result)
    }

    private func handleRemoveChildView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String,
              let childView = views[childId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid parent or child ID", details: nil))
            return
        }
        
        childView.removeFromSuperview()
        childViews[parentId]?.removeAll { $0 == childId }
        result(true)
    }

    private func handleGetViewById(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "View not found", details: nil))
            return
        }
        
        let viewInfo: [String: Any] = [
            "viewId": viewId,
            "type": String(describing: type(of: view)),
            "frame": [
                "x": view.frame.origin.x,
                "y": view.frame.origin.y,
                "width": view.frame.size.width,
                "height": view.frame.size.height
            ]
        ]
        
        result(viewInfo)
    }

    private func handleGetChildren(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let children = childViews[parentId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Parent not found", details: nil))
            return
        }
        
        result(children)
    }

    private func handleChangeViewBackgroundColor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let colorString = args["color"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        applyColorToView(view, colorString: colorString)
        result(true)
    }

    private func handleSetViewVisibility(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let isVisible = args["isVisible"] as? Bool,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        view.isHidden = !isVisible
        result(true)
    }

    internal func handleGetRootView(result: @escaping FlutterResult) {
        guard let rootViewId = self.rootViewId,
              let rootView = views[rootViewId] else {
            result(FlutterError(code: "NO_ROOT_VIEW", message: "Root view not initialized", details: nil))
            return
        }
        
        result([
            "viewId": rootViewId,
            "width": rootView.frame.width,
            "height": rootView.frame.height
        ])
    }
            
    private func cleanup() {
        for (_, recognizers) in registeredGestureRecognizers {
            for recognizer in recognizers {
                if let view = recognizer.view {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
        
        registeredGestureRecognizers.removeAll()
        
        for (_, view) in views {
            view.removeFromSuperview()
        }
        
        views.removeAll()
        childViews.removeAll()
    }
            
    deinit {
        cleanup()
    }
            
    private func createTouchableView() -> UIButton {
        let touchable = UIButton(type: .custom)
        touchable.backgroundColor = .clear
        touchable.adjustsImageWhenHighlighted = true
        touchable.showsTouchWhenHighlighted = true
        return touchable
    }

    @objc private func handleTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.6
        }
    }

    @objc private func handleTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
    }

    private func createButtonView() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.masksToBounds = true
        return button
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    private func handleSetViewLayout(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view ID", details: nil))
            return
        }
        
        // Create layout config from arguments        let config = LayoutConfig(from: args)                // Apply the layout        applyYogaLayout(to: view, config: config)                // Trigger layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        result(true)
    }

    private func applyLayout(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let layoutConfig = args as? [String: Any],
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for layout", details: nil))
            return
        }
        
        let config = LayoutConfig(from: layoutConfig)
        applyYogaLayout(to: view, config: config)
        
        // Trigger layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        result(true)
    }
}

extension UIView {
    func setupForBackground() {
        backgroundColor = .clear
        clipsToBounds = true
    }
}
