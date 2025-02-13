import UIKit
import Flutter

class NativeUIManager: NSObject, FlutterPlugin {
    private var methodChannel: FlutterMethodChannel?
    private var views: [String: UIView] = [:]
    private var childViews: [String: [String]] = [:]
    private var rootViewId: String?

    // Conforming to FlutterPlugin
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeUIManager()
        instance.methodChannel = FlutterMethodChannel(name: "com.dcmaui.framework", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)
        instance.setupRootView()
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createView":
            self.handleCreateView(call: call, result: result)
        case "attachView":
            self.handleAttachView(call: call, result: result)
        case "deleteView":
            self.handleDeleteView(call: call, result: result)
        case "updateView":
            self.handleUpdateView(call: call, result: result)
        case "setViewProperties":
            self.handleSetViewProperties(call: call, result: result)
        case "addChildView":
            self.handleAddChildView(call: call, result: result)
        case "removeChildView":
            self.handleRemoveChildView(call: call, result: result)
        case "getViewById":
            self.handleGetViewById(call: call, result: result)
        case "getChildren":
            self.handleGetChildren(call: call, result: result)
        case "changeViewBackgroundColor":
            self.handleChangeViewBackgroundColor(call: call, result: result)
        case "setViewVisibility":
            self.handleSetViewVisibility(call: call, result: result)
        case "registerEvent":
            self.handleRegisterEvent(call: call, result: result)
        case "unregisterEvent":
            self.handleUnregisterEvent(call: call, result: result)
        case "getRootView":
            self.handleGetRootView(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func setupRootView() {
    // Ensure you get the root view from the views dictionary
    guard let rootView = getRootView() else {
        print("Root view is nil")
        return
    }

    // Debugging: Confirm root view is initialized and added
    print("Root view added: \(rootView)")

    // Set background color for debugging to make sure it's visible
    rootView.backgroundColor = .green // Change as needed for visibility
    
    // Disable automatic constraints translation (use Auto Layout)
    rootView.translatesAutoresizingMaskIntoConstraints = false

    // Add the root view to the main window or view controller's view
    if let window = UIApplication.shared.windows.first {
        window.addSubview(rootView)
        
        // Add layout constraints to ensure the root view fills the screen
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: window.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        
        print("Root view constraints set successfully.")
    }

    // Further setup for any child views or additional configurations
    setupChildViews(for: rootView)
}

// Assuming you have other child views to set up within the root view
func setupChildViews(for rootView: UIView) {
    // Example: Add a UIButton to the root view
    let button = UIButton(type: .system)
    button.setTitle("Click Me", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    rootView.addSubview(button)

    // Set constraints for the button
    NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
        button.centerYAnchor.constraint(equalTo: rootView.centerYAnchor)
    ])

    // Make sure the button's background color is visible for debugging
    button.backgroundColor = .yellow // Change as needed

    // Add more child views as needed and ensure proper constraints
}


    func getRootView() -> UIView? {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first
            else {
                return nil
            }
            return window.rootViewController?.view
        } else {
            return UIApplication.shared.keyWindow?.rootViewController?.view
        }
    }

    @objc private func handleButtonClick(_ sender: UIButton) {
        sendEventToFlutter(view: sender, eventType: "onClick")
    }

    @objc private func handleViewTap(_ sender: UITapGestureRecognizer) {
        sendEventToFlutter(view: sender.view, eventType: "onClick")
    }

    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            sendEventToFlutter(view: sender.view, eventType: "onLongPress")
        }
    }

    private func sendEventToFlutter(view: UIView?, eventType: String, extraData: [String: Any] = [:]) {
        guard let view = view else { return }
        guard let viewId = views.first(where: { $0.value == view })?.key else { return }

        var eventData: [String: Any] = ["viewId": viewId, "eventType": eventType]
        eventData.merge(extraData) { (_, new) in new }

        methodChannel?.invokeMethod("onNativeEvent", arguments: eventData)
    }

    // MARK: - Handler Methods

    func handleGetRootView(call: FlutterMethodCall, result: FlutterResult) {
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

    func handleCreateView(call: FlutterMethodCall, result: FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewType = args["viewType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing viewType", details: nil))
            return
        }

        let viewId = UUID().uuidString
        var view: UIView?

        switch viewType {
        case "Container":
            view = UIView()
        case "Button":
            let button = UIButton(type: .system)
            button.setTitle(args["title"] as? String ?? "Button", for: .normal)
            view = button
        case "Label":
            let label = UILabel()
            label.text = args["text"] as? String ?? "Label"
            view = label
        case "TextField":
            view = UITextField()
        case "ImageView":
            view = UIImageView()
        case "ScrollView":
            view = UIScrollView()
        case "StackView":
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.distribution = .fill
            view = stackView
        default:
            result(FlutterError(code: "INVALID_TYPE", message: "Unknown view type: \(viewType)", details: nil))
            return
        }

        if let view = view {
            // Set background color to red for testing
            view.backgroundColor = .red

            view.translatesAutoresizingMaskIntoConstraints = false
            views[viewId] = view
            childViews[viewId] = []
            result(viewId)
        } else {
            result(FlutterError(code: "CREATION_FAILED", message: "Failed to create view", details: nil))
        }
    }

    
    func handleAttachView(call: FlutterMethodCall, result: FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String,
              let parentView = views[parentId],
              let childView = views[childId] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid parentId or childId", details: nil))
            return
        }
        
        if parentId == rootViewId {
            parentView.addSubview(childView)
            NSLayoutConstraint.activate([
                childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                childView.topAnchor.constraint(equalTo: parentView.topAnchor),
                childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
        } else if let stackView = parentView as? UIStackView {
            stackView.addArrangedSubview(childView)
        } else {
            parentView.addSubview(childView)
        }
        
        childViews[parentId]?.append(childId)
        result(true)
    }
    
    func handleDeleteView(call: FlutterMethodCall, result: FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let viewToRemove = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "View not found", details: nil))
            return
        }
        
        viewToRemove.removeFromSuperview()
        views.removeValue(forKey: viewId)
        childViews.removeValue(forKey: viewId)
        
        for (parentId, children) in childViews {
            if children.contains(viewId) {
                childViews[parentId]?.removeAll { $0 == viewId }
            }
        }
        
        result(true)
    }
    
    func handleUpdateView(call: FlutterMethodCall, result: FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let properties = args["properties"] as? [String: Any],
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            if let button = view as? UIButton {
                if let title = properties["title"] as? String {
                    button.setTitle(title, for: .normal)
                }
            } else if let label = view as? UILabel {
                if let text = properties["text"] as? String {
                    label.text = text
                }
            } else if let textField = view as? UITextField {
                if let text = properties["text"] as? String {
                    textField.text = text
                }
                if let placeholder = properties["placeholder"] as? String {
                    textField.placeholder = placeholder
                }
            } else if let stackView = view as? UIStackView {
                if let spacing = properties["spacing"] as? CGFloat {
                    stackView.spacing = spacing
                }
                if let axis = properties["axis"] as? String {
                    stackView.axis = axis == "horizontal" ? .horizontal : .vertical
                }
            }
            
            if let frame = properties["frame"] as? [String: CGFloat] {
                view.frame = CGRect(
                    x: frame["x"] ?? view.frame.origin.x,
                    y: frame["y"] ?? view.frame.origin.y,
                    width: frame["width"] ?? view.frame.size.width,
                    height: frame["height"] ?? view.frame.size.height
                )
            }
        }
        
        result(true)
    }
    
    func handleSetViewProperties(call: FlutterMethodCall, result: FlutterResult) {
        handleUpdateView(call: call, result: result)
    }
    
    func handleAddChildView(call: FlutterMethodCall, result: FlutterResult) {
        handleAttachView(call: call, result: result)
    }
    
    func handleRemoveChildView(call: FlutterMethodCall, result: FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String,
              let childView = views[childId] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid parentId or childId", details: nil))
            return
        }
        
        childView.removeFromSuperview()
        childViews[parentId]?.removeAll { $0 == childId }
        result(true)
    }
    
    func handleGetViewById(call: FlutterMethodCall, result: FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "View not found", details: nil))
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
    
    func handleGetChildren(call: FlutterMethodCall, result: FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let children = childViews[parentId] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Parent not found", details: nil))
            return
        }
        
        result(children)
    }
    
    func handleChangeViewBackgroundColor(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let colorString = args["color"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            switch colorString.lowercased() {
            case "red": view.backgroundColor = .red
            case "blue": view.backgroundColor = .blue
            case "green": view.backgroundColor = .green
            case "yellow": view.backgroundColor = .yellow
            case "black": view.backgroundColor = .black
            case "white": view.backgroundColor = .white
            case "clear": view.backgroundColor = .clear
            default:
                if let color = UIColor(named: colorString) {
                    view.backgroundColor = color
                }
            }
        }
        
        result(true)
    }
                
                func handleSetViewVisibility(call: FlutterMethodCall, result: FlutterResult) {
                    guard let args = call.arguments as? [String: Any],
                          let viewId = args["viewId"] as? String,
                          let isVisible = args["isVisible"] as? Bool,
                          let view = views[viewId] else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                        return
                    }
                    
                    DispatchQueue.main.async {
                        view.isHidden = !isVisible
                    }
                    
                    result(true)
                }
                
                func handleRegisterEvent(call: FlutterMethodCall, result: FlutterResult) {
                    guard let args = call.arguments as? [String: Any],
                          let viewId = args["viewId"] as? String,
                          let eventType = args["eventType"] as? String,
                          let view = views[viewId] else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                        return
                    }
                    
                    switch eventType {
                    case "onClick":
                        if view is UIButton {
                            (view as? UIButton)?.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
                        } else {
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
                            view.addGestureRecognizer(tapGesture)
                        }
                    case "onLongPress":
                        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                        view.addGestureRecognizer(longPressGesture)
                    default:
                        result(FlutterError(code: "INVALID_EVENT", message: "Unknown event type: \(eventType)", details: nil))
                        return
                    }
                    
                    result(true)
                }
                
                func handleUnregisterEvent(call: FlutterMethodCall, result: FlutterResult) {
                    guard let args = call.arguments as? [String: Any],
                          let viewId = args["viewId"] as? String,
                          let eventType = args["eventType"] as? String,
                          let view = views[viewId] else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                        return
                    }
                    
                    switch eventType {
                    case "onClick":
                        if view is UIButton {
                            (view as? UIButton)?.removeTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
                        } else {
                            view.gestureRecognizers?.removeAll { $0 is UITapGestureRecognizer }
                        }
                    case "onLongPress":
                        view.gestureRecognizers?.removeAll { $0 is UILongPressGestureRecognizer }
                    default:
                        result(FlutterError(code: "INVALID_EVENT", message: "Unknown event type: \(eventType)", details: nil))
                        return
                    }
                    
                    result(true)
                }
            }
