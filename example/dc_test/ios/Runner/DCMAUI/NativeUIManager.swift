import UIKit
import Flutter
import yoga  

enum StackType: String {
    case vertical
    case horizontal
    case depth
}

enum TouchEventType: String {
    case onPress
    case onLongPress
    case onPressIn
    case onPressOut
    case onDoublePress
}

enum ButtonEventType: String {
    case onClick
    case onLongPress
    case onPressIn
    case onPressOut
}

enum GestureEventType: String {
    case onTap
    case onDoubleTap
    case onLongPress
    case onPanStart
    case onPanUpdate
    case onPanEnd
    case onScaleStart
    case onScaleUpdate
    case onScaleEnd
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
    
    private var touchEventHandlers: [String: [TouchEventType: () -> Void]] = [:]
    private var buttonEventHandlers: [String: [ButtonEventType: () -> Void]] = [:]
    private var gestureEventHandlers: [String: [GestureEventType: () -> Void]] = [:]

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
            rootView.yoga.isEnabled = true // Enable yoga on root
            rootView.yoga.flexDirection = .column
            rootView.yoga.width = YGValue(value: Float(rootVC.view.bounds.width), unit: .point)
            rootView.yoga.height = YGValue(value: Float(rootVC.view.bounds.height), unit: .point)
            
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
            
            switch call.method {
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
            
            // Setup event handlers immediately
            print("Setting up button events for new button")
            button.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(handleButtonPressIn(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(handleButtonPressOut(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleButtonLongPress(_:)))
            button.addGestureRecognizer(longPress)
            
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
            
            view = button
            print("Button creation complete with ID: \(viewId)")

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
            
        case "TouchableOpacity":
            let touchable = createTouchableView()
            setupTouchableEvents(touchable)
            touchable.alpha = 1.0
            touchable.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
            touchable.addTarget(self, action: #selector(handleTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            view = touchable
            
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

    private func handleRegisterEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventTypeStr = args["eventType"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        // Convert eventType string to proper enum
        if let buttonEvent = ButtonEventType(rawValue: eventTypeStr) {
            setupButtonEvent(view, viewId: viewId, eventType: buttonEvent)
            result(true)
            return
        }
        
        if let touchEvent = TouchEventType(rawValue: eventTypeStr) {
            setupTouchEvent(view, viewId: viewId, eventType: touchEvent)
            result(true)
            return
        }
        
        result(FlutterError(code: "INVALID_EVENT", message: "Unknown event type: \(eventTypeStr)", details: nil))
    }

    private func setupButtonEvent(_ view: UIView, viewId: String, eventType: ButtonEventType) {
        guard let button = view as? UIButton else { return }
        
        switch eventType {
        case .onClick:
            button.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        case .onLongPress:
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleButtonLongPress(_:)))
            button.addGestureRecognizer(longPress)
        case .onPressIn:
            button.addTarget(self, action: #selector(handleButtonPressIn(_:)), for: .touchDown)
        case .onPressOut:
            button.addTarget(self, action: #selector(handleButtonPressOut(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }

    private func setupTouchEvent(_ view: UIView, viewId: String, eventType: TouchEventType) {
        switch eventType {
        case .onPress:
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTouchablePress(_:)))
            view.addGestureRecognizer(tap)
        case .onDoublePress:
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleTouchableDoublePress(_:)))
            doubleTap.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTap)
        case .onLongPress:
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleTouchableLongPress(_:)))
            view.addGestureRecognizer(longPress)
        case .onPressIn:
            if let button = view as? UIButton {
                button.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
            }
        case .onPressOut:
            if let button = view as? UIButton {
                button.addTarget(self, action: #selector(handleTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            }
        }
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
            
            @objc private func handleButtonClick(_ sender: UIButton) {
                guard let viewId = views.first(where: { $0.value == sender })?.key else {
                    print("Warning: Could not find viewId for clicked button")
                    return
                }
                print("Button click detected for viewId: \(viewId)") // Debug log
                
                // Send event to Flutter
                let eventData: [String: Any] = [
                    "viewId": viewId,
                    "type": ButtonEventType.onClick.rawValue,
                    "timestamp": Date().timeIntervalSince1970
                ]
                
                methodChannel?.invokeMethod("onButtonEvent", arguments: eventData, result: { result in
                    if let error = result as? FlutterError {
                        print("Error sending button event: \(error.message ?? "unknown")")
                    } else {
                        print("Button event sent successfully")
                    }
                })
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

    private func setupButtonEvents(_ button: UIButton) {
        print("Setting up button events") // Debug log
        button.addTarget(self, action: #selector(handleButtonPressIn(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(handleButtonPressOut(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        button.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleButtonLongPress(_:)))
        button.addGestureRecognizer(longPress)
        print("Button events setup complete") // Debug log
    }

    private func setupTouchableEvents(_ view: UIView) {
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTouchablePress(_:)))
        view.addGestureRecognizer(tap)
        
        // Double tap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleTouchableDoublePress(_:)))
        doubleTap.numberOfTapsRequired = 2
        tap.require(toFail: doubleTap)
        view.addGestureRecognizer(doubleTap)
        
        // Long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleTouchableLongPress(_:)))
        view.addGestureRecognizer(longPress)
    }

    @objc private func handleButtonPress(_ sender: UIButton) {
        guard let viewId = getViewId(for: sender) else { return }
        sendButtonEvent(viewId: viewId, type: .onPressIn)
    }

    @objc private func handleButtonPressUp(_ sender: UIButton) {
        guard let viewId = getViewId(for: sender) else { return }
        sendButtonEvent(viewId: viewId, type: .onPressOut)
        sendButtonEvent(viewId: viewId, type: .onClick)
    }

    @objc private func handleButtonLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let button = sender.view as? UIButton,
              let viewId = getViewId(for: button) else { return }
        
        if sender.state == .began {
            sendButtonEvent(viewId: viewId, type: .onLongPress)
        }
    }

    @objc private func handleTouchablePress(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let viewId = getViewId(for: view) else { return }
        
        let location = sender.location(in: view)
        sendTouchEvent(viewId: viewId, type: .onPress, location: location)
    }

    @objc private func handleTouchableDoublePress(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let viewId = getViewId(for: view) else { return }
        
        let location = sender.location(in: view)
        sendTouchEvent(viewId: viewId, type: .onDoublePress, location: location)
    }

    private func sendTouchEvent(viewId: String, type: TouchEventType, location: CGPoint) {
        let eventData: [String: Any] = [
            "viewId": viewId,
            "type": type.rawValue,
            "x": location.x,
            "y": location.y,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        methodChannel?.invokeMethod("onTouchEvent", arguments: eventData)
    }

    private func sendButtonEvent(viewId: String, type: ButtonEventType) {
        print("Sending button event: \(type.rawValue) for view: \(viewId)") // Debug log
        let eventData: [String: Any] = [
            "viewId": viewId,
            "type": type.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        methodChannel?.invokeMethod("onButtonEvent", arguments: eventData)
    }

    private func getViewId(for view: UIView) -> String? {
        return views.first(where: { $0.value == view })?.key
    }

    @objc private func handleButtonPressIn(_ sender: UIButton) {
        guard let viewId = views.first(where: { $0.value == sender })?.key else { return }
        print("Button press in: \(viewId)")
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        sendButtonEvent(viewId: viewId, type: .onPressIn)
    }

    @objc private func handleButtonPressOut(_ sender: UIButton) {
        guard let viewId = views.first(where: { $0.value == sender })?.key else { return }
        print("Button press out: \(viewId)")
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
        sendButtonEvent(viewId: viewId, type: .onPressOut)
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

    @objc private func handleTouchableLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let view = sender.view,
              let viewId = getViewId(for: view) else { return }
        
        if sender.state == .began {
            let location = sender.location(in: view)
            sendTouchEvent(viewId: viewId, type: .onLongPress, location: location)
        }
    }
}

extension UIView {
    func setupForBackground() {
        backgroundColor = .clear
        clipsToBounds = true
    }
}
