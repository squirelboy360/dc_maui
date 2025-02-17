import UIKit
import Flutter
import yoga  // Add this import

enum StackType: String {
    case vertical
    case horizontal
    case depth
}

@available(iOS 13.0, *)
class NativeUIManager: NSObject, FlutterPlugin {
    private var methodChannel: FlutterMethodChannel?
    internal var views: [String: UIView] = [:]
    internal var childViews: [String: [String]] = [:]
    private var rootViewId: String?
    private var window: UIWindow?
    private var registeredGestureRecognizers: [String: [UIGestureRecognizer]] = [:]
    internal var layoutConfigs: [String: LayoutConfig] = [:]
    internal var yogaNodes: [String: YGNodeRef] = [:]
    
    static func register(with registrar: FlutterPluginRegistrar) {
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
    private func setupRootView() {
        print("Setting up root view")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            window = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window?.windowScene = windowScene
            
            let rootVC = UIViewController()
            rootVC.view.backgroundColor = .white
            print("Root view controller frame: \(rootVC.view.frame)")
            
            let rootView = UIView(frame: rootVC.view.bounds)
            rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            rootView.backgroundColor = .white
            print("Root view frame: \(rootView.frame)")
            
            rootVC.view.addSubview(rootView)
            
            rootViewId = "root-\(UUID().uuidString)"
            views[rootViewId!] = rootView
            childViews[rootViewId!] = []
            
            window?.rootViewController = rootVC
            window?.makeKeyAndVisible()
            
            print("Root view setup complete with ID: \(rootViewId!)")
            print("Window frame: \(window?.frame ?? .zero)")
        }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // First try to handle value API methods
            self.addValueAPIMethodHandlers(call, result: result)
            
            // Then proceed with existing switch statement
            switch call.method {
            case "getRootView":
                guard let rootViewId = self.rootViewId,
                      let rootView = self.views[rootViewId] else {
                    result(FlutterError(code: "NO_ROOT_VIEW", message: "Root view not initialized", details: nil))
                    return
                }
                
                result([
                    "viewId": rootViewId,
                    "width": rootView.frame.width,
                    "height": rootView.frame.height
                ])
                
            case "createView":
                self.handleCreateView(call, result: result)
                
            case "attachView":
                self.handleAttachView(call, result: result)
            case "deleteView":
                self.handleDeleteView(call, result: result)
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
            case "registerEvent":
                self.handleRegisterEvent(call, result: result)
            case "unregisterEvent":
                self.handleUnregisterEvent(call, result: result)
            case "getRootView":
                self.handleGetRootView(result: result)
            case "createStackView":
                self.handleCreateStackView(call, result: result)
            case "createListView":
                self.handleCreateListView(call, result: result)
            case "setViewLayout":
                self.handleSetViewLayout(call, result: result)
            case "createScrollView":
                self.handleCreateScrollView(call, result: result)
            case "setScrollContent":
                self.handleSetScrollContent(call, result: result)
            case "applyLayout":  // Add this case to handle layout application
                self.applyLayout(call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func handleCreateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Creating view with arguments: \(String(describing: call.arguments))")
        
        guard let args = call.arguments as? [String: Any],
              let viewType = args["viewType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing viewType", details: nil))
            return
        }
        
        let view: UIView?
        let viewId = "\(viewType.lowercased())-\(UUID().uuidString)"
        
        switch viewType {
        case "View":
            let containerView = UIView(frame: .zero)
            containerView.backgroundColor = .clear
            view = containerView
            
        case "Label":
            let label = UILabel()
            label.text = (args["properties"] as? [String: Any])?["text"] as? String
            label.textAlignment = .center
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            view = label
            
        case "Button":
            let button = UIButton(type: .system)
            if let properties = args["properties"] as? [String: Any] {
                button.setTitle(properties["text"] as? String, for: .normal)
                if let textStyle = (properties["textStyle"] as? [String: Any]) {
                    if let fontSize = textStyle["fontSize"] as? CGFloat {
                        button.titleLabel?.font = .systemFont(ofSize: fontSize)
                    }
                }
            }
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.masksToBounds = true
            view = button
            
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
        
        // Different attachment behavior based on parent view type
        if let stackView = parentView as? UIStackView {
            stackView.addArrangedSubview(childView)
        } else if parentView is ZStackView {
            parentView.addSubview(childView)
            // ZStackView will handle its own constraints in addSubview
        } else {
            parentView.addSubview(childView)
            // Default centering behavior for regular views
            NSLayoutConstraint.activate([
                childView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                childView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
            ])
        }
        
        childViews[parentId]?.append(childId)
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

    private func handleUpdateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let properties = args["properties"] as? [String: Any],
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
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

    private func handleRegisterEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventType = args["eventType"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let gesture: UIGestureRecognizer
        
        switch eventType {
        case "onClick":
            if let button = view as? UIButton {
                button.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
                result(true)
                return
            } else {
                gesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
            }
        case "onLongPress":
            gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        default:
            result(FlutterError(code: "INVALID_EVENT", message: "Unknown event type", details: nil))
            return
        }
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
        
        registeredGestureRecognizers[viewId, default: []].append(gesture)
        result(true)
    }

    private func handleUnregisterEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventType = args["eventType"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        if let button = view as? UIButton, eventType == "onClick" {
            button.removeTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        } else {
            registeredGestureRecognizers[viewId]?.forEach { gesture in
                view.removeGestureRecognizer(gesture)
            }
            registeredGestureRecognizers.removeValue(forKey: viewId)
        }
        
        result(true)
    }

    private func handleGetRootView(result: @escaping FlutterResult) {
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
            
            @objc private func handleButtonClick(_ sender: UIButton) {
                guard let viewId = views.first(where: { $0.value == sender })?.key else {
                    print("Warning: Could not find viewId for clicked button")
                    return
                }
                print("Native button click detected for viewId: \(viewId)")
                sendEventToFlutter(viewId: viewId, eventType: "onClick")
            }
            
            @objc private func handleViewTap(_ sender: UITapGestureRecognizer) {
                guard let view = sender.view,
                      let viewId = views.first(where: { $0.value == view })?.key else { return }
                sendEventToFlutter(viewId: viewId, eventType: "onClick")
            }
            
            @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
                guard sender.state == .began,
                      let view = sender.view,
                      let viewId = views.first(where: { $0.value == view })?.key else { return }
                sendEventToFlutter(viewId: viewId, eventType: "onLongPress")
            }
            
            private func sendEventToFlutter(viewId: String, eventType: String) {
                // Explicitly type the dictionary
                let eventData: [String: Any] = [
                    "viewId": viewId as String,
                    "eventType": eventType as String,
                    "timestamp": Date().timeIntervalSince1970 as Double
                ]
                
                DispatchQueue.main.async { [weak self] in
                    self?.methodChannel?.invokeMethod(
                        "onNativeEvent",
                        arguments: eventData as [String: Any],
                        result: { (result) in
                            if let error = result as? FlutterError {
                                print("Warning: Event callback completed with error: \(error.message ?? "unknown")")
                            } else if FlutterMethodNotImplemented.isEqual(result) {
                                print("Warning: Event callback not implemented on Flutter side")
                            } else {
                                print("Event successfully delivered to Flutter: \(eventType) for view \(viewId)")
                            }
                        }
                    )
                }
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
                    if let button = view as? UIButton {
                        button.removeTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
                    }
                    view.removeFromSuperview()
                }
                
                views.removeAll()
                childViews.removeAll()
            }
            
            deinit {
                cleanup()
            }
            
        }

@available(iOS 13.0, *)
extension NativeUIManager {
    private func handleCreateStackView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let stackTypeString = args["stackType"] as? String,
              let stackType = StackType(rawValue: stackTypeString) else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid stack type", details: nil))
            return
        }

        let stackView: UIView
        let viewId = "stack-\(stackType.rawValue)-\(UUID().uuidString)"

        switch stackType {
        case .vertical:
            let vStack = UIStackView()
            vStack.axis = .vertical
            vStack.spacing = args["spacing"] as? CGFloat ?? 8.0
            stackView = vStack
            
        case .horizontal:
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = args["spacing"] as? CGFloat ?? 8.0
            stackView = hStack
            
        case .depth:
            // For ZStack, we use a regular view that overlays its subviews
            let zStack = ZStackView()
            stackView = zStack
        }

        if let stackView = stackView as? UIStackView {
            if let alignment = args["alignment"] as? String {
                stackView.alignment = convertAlignment(alignment)
            }
        }

        // Apply padding if provided
        if let padding = args["padding"] as? [String: CGFloat] {
            stackView.layoutMargins = UIEdgeInsets(
                top: padding["top"] ?? 0,
                left: padding["left"] ?? 0,
                bottom: padding["bottom"] ?? 0,
                right: padding["right"] ?? 0
            )
            if let stackView = stackView as? UIStackView {
                stackView.isLayoutMarginsRelativeArrangement = true
            }
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        views[viewId] = stackView
        childViews[viewId] = []
        
        result(viewId)
    }

    private func convertAlignment(_ alignment: String) -> UIStackView.Alignment {
        switch alignment {
        case "start": return .leading
        case "center": return .center
        case "end": return .trailing
        case "stretch": return .fill
        default: return .fill
        }
    }

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
}

extension UIView {
    func setupForBackground() {
        backgroundColor = .clear
        clipsToBounds = true
    }
}
