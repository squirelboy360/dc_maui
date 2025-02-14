import UIKit
import Flutter
import os.log 

@available(iOS 13.0, *)
class NativeUIManager: NSObject, FlutterPlugin {
    private let logger = OSLog(subsystem: "com.dcmaui.framework", category: "NativeUIManager") // Use OSLog instead of Logger
    internal var methodChannel: FlutterMethodChannel?
    internal var views: [String: UIView] = [:]
    internal var childViews: [String: [String]] = [:]
    internal var rootViewId: String?
    internal var window: UIWindow?
    private var registeredGestureRecognizers: [String: [UIGestureRecognizer]] = [:]
    private var stateBindings: [String: Set<String>] = [:]
    internal var navigationController: NativeNavigationController?  // Keep this
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeUIManager()
        let channel = FlutterMethodChannel(
            name: "com.dcmaui.framework",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.methodChannel = channel
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            instance.setupRootView()
        }
    }
    
    private func setupRootView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Create a new window with the correct frame
            window = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window?.windowScene = windowScene
            
            // Create navigation controller as root
            setupNavigationController()
            
            // Log success
            os_log(.info, log: logger, "Native UI window setup complete with root view: %{public}@", rootViewId ?? "none")
        }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch call.method {
            // Add this case first to handle navigation setup
            case "setupNavigation":
                if let args = call.arguments as? [String: Any],
                   let typeStr = args["type"] as? String {
                    // Create navigation controller if needed
                    if self.navigationController == nil {
                        self.setupNavigationController()
                    }
                    result(true)
                    return
                }
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid navigation setup args", details: nil))
                
            // Your existing cases...
            case "createView":
                self.handleCreateView(call, result: result)
            // ...other existing cases...
            case "pushScreen", "popScreen", "presentModal",
                 "dismissModal", "setupTabs", "switchTab":
                self.handleNavigationMethod(call, result: result)
                
            // View Creation
            case "createView":
                self.handleCreateView(call, result: result)
                
            // View Hierarchy
            case "attachView":
                self.handleAttachView(call, result: result)
            case "detachView":
                self.handleDetachView(call, result: result)
            case "deleteView":
                self.handleDeleteView(call, result: result)
            case "getRootView":
                self.handleGetRootView(result: result)
            case "getViewById":
                self.handleGetViewById(call, result: result)
            case "getChildren":
                self.handleGetChildren(call, result: result)
            
            // View Properties
            case "updateView":
                self.handleUpdateView(call, result: result)
            case "setViewProperties":
                self.handleSetViewProperties(call, result: result)
            case "changeViewBackgroundColor":
                self.handleChangeViewBackgroundColor(call, result: result)
            case "setViewVisibility":
                self.handleSetViewVisibility(call, result: result)
            case "setViewSize":
                self.handleSetViewSize(call, result: result)
            case "setViewMargin":
                self.handleSetViewMargin(call, result: result)
            case "setViewPadding":
                self.handleSetViewPadding(call, result: result)
            case "setViewBorder":
                self.handleSetViewBorder(call, result: result)
            case "setViewCornerRadius":
                self.handleSetViewCornerRadius(call, result: result)
            case "setViewShadow":
                self.handleSetViewShadow(call, result: result)
            case "setViewOpacity":
                self.handleSetViewOpacity(call, result: result)
            case "setViewTransform":
                self.handleSetViewTransform(call, result: result)
                
            // Events
            case "registerEvent":
                self.handleRegisterEvent(call, result: result)
            case "unregisterEvent":
                self.handleUnregisterEvent(call, result: result)
                
            // State Management
            case "onStateChange":
                self.handleStateChange(call, result: result)
                
            // Add to handleMethodCall
            case "showAlert":
                self.handleShowAlert(call, result: result)
                
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
        
        let view: UIView?
        let viewId = "\(viewType.lowercased())-\(UUID().uuidString)"
        
        switch viewType {
        // Layout Components
        case "StackView":
            let stackView = UIStackView()
            stackView.axis = (args["axis"] as? String == "horizontal") ? .horizontal : .vertical
            stackView.spacing = args["spacing"] as? CGFloat ?? 8
            stackView.alignment = .fill
            stackView.distribution = .fill
            view = stackView
            
        case "ScrollView":
            let scrollView = UIScrollView()
            scrollView.alwaysBounceVertical = true
            view = scrollView
            
        case "CollectionView":
            let layout = UICollectionViewFlowLayout()
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            view = collectionView
            
        // Input Components
        case "Button":
            let button = UIButton(type: .system)
            button.setTitle(args["title"] as? String ?? "", for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            view = button
            
        case "TextField":
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.placeholder = args["placeholder"] as? String
            textField.text = args["text"] as? String
            view = textField
            
        case "TextView":
            let textView = UITextView()
            textView.text = args["text"] as? String
            textView.font = .systemFont(ofSize: args["fontSize"] as? CGFloat ?? 17)
            view = textView
            
        case "Switch":
            let switchView = UISwitch()
            switchView.isOn = args["value"] as? Bool ?? false
            view = switchView
            
        case "Slider":
            let slider = UISlider()
            slider.minimumValue = args["min"] as? Float ?? 0
            slider.maximumValue = args["max"] as? Float ?? 1
            slider.value = args["value"] as? Float ?? 0
            view = slider
            
        // Display Components
        case "Label":
            let label = UILabel()
            label.text = args["text"] as? String ?? ""
            label.textAlignment = .center
            label.numberOfLines = args["maxLines"] as? Int ?? 0
            view = label
            
        case "ImageView":
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            if let urlString = args["url"] as? String,
               let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }.resume()
            }
            view = imageView
            
        case "ProgressView":
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.progress = args["progress"] as? Float ?? 0
            view = progressView
            
        case "ActivityIndicator":
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            if args["isAnimating"] as? Bool ?? false {
                activityIndicator.startAnimating()
            }
            view = activityIndicator
            
        // Container Components
        case "View":
            view = UIView()
            
        case "SafeAreaView":
            let safeAreaView = UIView()
            safeAreaView.insetsLayoutMarginsFromSafeArea = true
            view = safeAreaView
            
        default:
            view = UIView()
            os_log(.info, log: logger, "⚠️ Unknown view type: %{public}@", viewType)
        }
        
        view?.translatesAutoresizingMaskIntoConstraints = false
        
        if let view = view {
            views[viewId] = view
            childViews[viewId] = []
            result(viewId)
        } else {
            result(FlutterError(code: "CREATION_FAILED", message: "Failed to create view", details: nil))
        }
    }

    private func handleAttachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
           guard let args = call.arguments as? [String: Any],
                 let parentId = args["parentId"] as? String,
                 let childId = args["childId"] as? String,
                 let parentView = views[parentId],
                 let childView = views[childId] else {
               result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid parent or child ID", details: nil))
               return
           }
           
           if let stackView = parentView as? UIStackView {
               stackView.addArrangedSubview(childView)
           } else {
               parentView.addSubview(childView)
               
               NSLayoutConstraint.activate([
                   childView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
                   childView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
                   childView.widthAnchor.constraint(lessThanOrEqualTo: parentView.widthAnchor, constant: -32)
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
            
            private func handleStateChange(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
                guard let args = call.arguments as? [String: Any],
                      let key = args["key"] as? String,
                      let value = args["value"],
                      let affectedViews = args["affectedViews"] as? [String] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid state change arguments", details: nil))
                    return
                }
                
                // Update state bindings
                stateBindings[key] = Set(affectedViews)
                
                // Update views
                for viewId in affectedViews {
                    guard let view = views[viewId] else { continue }
                    
                    // Apply state update based on view type
                    switch view {
                    case let label as UILabel:
                        label.text = "\(value)"
                        
                    case let button as UIButton:
                        if key.hasSuffix("Title") {
                            button.setTitle("\(value)", for: .normal)
                        }
                        
                    default:
                        break
                    }
                }
                
                // Notify success
                result(true)
                
                // Notify Flutter of successful state update
                let updateInfo: [String: Any] = [
                    "key": key,
                    "value": value,
                    "updatedViews": affectedViews
                ]
                methodChannel?.invokeMethod("onStateUpdateComplete", arguments: updateInfo)
            }
            
            @objc private func handleButtonClick(_ sender: UIButton) {
                guard let viewId = views.first(where: { $0.value == sender })?.key else { return }
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
                let eventData: [String: Any] = [
                    "viewId": viewId,
                    "eventType": eventType,
                    "timestamp": Date().timeIntervalSince1970
                ]
                
                methodChannel?.invokeMethod("onNativeEvent", arguments: eventData)
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

        extension UIView {
            var parentViewController: UIViewController? {
                var responder: UIResponder? = self
                while let nextResponder = responder?.next {
                    if let viewController = nextResponder as? UIViewController {
                        return viewController
                    }
                    responder = nextResponder
                }
                return nil
            }
        }

@available(iOS 13.0, *)
extension NativeUIManager {
    // Add missing view property methods
    private func handleSetViewSize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let width = args["width"] as? CGFloat,
              let height = args["height"] as? CGFloat,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid size arguments", details: nil))
            return
        }
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.heightAnchor.constraint(equalToConstant: height)
        ])
        result(true)
    }
    
    private func handleSetViewMargin(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let margins = args["margins"] as? [String: CGFloat],
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid margin arguments", details: nil))
            return
        }
        
        if let superview = view.superview {
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: margins["top"] ?? 0),
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margins["left"] ?? 0),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -(margins["right"] ?? 0)),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -(margins["bottom"] ?? 0))
            ])
        }
        result(true)
    }
    
    private func handleSetViewPadding(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let padding = args["padding"] as? [String: CGFloat],
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid padding arguments", details: nil))
            return
        }
        
        if let stackView = view as? UIStackView {
            stackView.layoutMargins = UIEdgeInsets(
                top: padding["top"] ?? 0,
                left: padding["left"] ?? 0,
                bottom: padding["bottom"] ?? 0,
                right: padding["right"] ?? 0
            )
            stackView.isLayoutMarginsRelativeArrangement = true
        }
        result(true)
    }
    
    private func handleSetViewBorder(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let width = args["width"] as? CGFloat,
              let color = args["color"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid border arguments", details: nil))
            return
        }
        
        view.layer.borderWidth = width
        view.layer.borderColor = UIColor(named: color)?.cgColor ?? UIColor.black.cgColor
        result(true)
    }
    
    private func handleSetViewCornerRadius(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let radius = args["radius"] as? CGFloat,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid corner radius arguments", details: nil))
            return
        }
        
        view.layer.cornerRadius = radius
        view.clipsToBounds = true
        result(true)
    }

    // Add new method to handle view shadow
    private func handleSetViewShadow(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid shadow arguments", details: nil))
            return
        }
        
        view.layer.shadowColor = UIColor(named: args["color"] as? String ?? "black")?.cgColor
        view.layer.shadowOffset = CGSize(
            width: args["offsetX"] as? CGFloat ?? 0,
            height: args["offsetY"] as? CGFloat ?? 2
        )
        view.layer.shadowRadius = args["radius"] as? CGFloat ?? 4
        view.layer.shadowOpacity = Float(args["opacity"] as? CGFloat ?? 0.25)
        result(true)
    }

    // Add new method to handle view transform
    private func handleSetViewTransform(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid transform arguments", details: nil))
            return
        }
        
        var transform = CGAffineTransform.identity
        
        if let rotation = args["rotation"] as? CGFloat {
            transform = transform.rotated(by: rotation)
        }
        
        if let scale = args["scale"] as? CGFloat {
            transform = transform.scaledBy(x: scale, y: scale)
        }
        
        if let translateX = args["translateX"] as? CGFloat,
           let translateY = args["translateY"] as? CGFloat {
            transform = transform.translatedBy(x: translateX, y: translateY)
        }
        
        view.transform = transform
        result(true)
    }

    private func handleDetachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
    
    private func handleSetViewOpacity(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let opacity = args["opacity"] as? CGFloat,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid opacity arguments", details: nil))
            return
        }
        
        view.alpha = opacity
        result(true)
    }
    
    private func handleSetupNavigation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
           let typeStr = args["type"] as? String {
            // Create navigation controller if needed
            if navigationController == nil {
                setupNavigationController()
                os_log(.info, log: logger, "Navigation controller setup complete")
            }
            result(true)
            return
        }
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid navigation setup args", details: nil))
    }

    // Add method implementation
    private func handleShowAlert(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let title = args["title"] as? String,
              let message = args["message"] as? String,
              let actions = args["actions"] as? [[String: Any]] else {
            result(false)
            return
        }
        
        let alertStyle: UIAlertController.Style = 
            (args["style"] as? String == "actionSheet") ? .actionSheet : .alert
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        
        for action in actions {
            guard let title = action["title"] as? String else { continue }
            
            let style: UIAlertAction.Style
            switch action["style"] as? String {
            case "cancel": style = .cancel
            case "destructive": style = .destructive
            default: style = .default
            }
            
            let alertAction = UIAlertAction(title: title, style: style) { [weak self] _ in
                self?.methodChannel?.invokeMethod("onAlertAction", arguments: [
                    "title": title
                ])
            }
            alert.addAction(alertAction)
        }
        
        if let topVC = UIApplication.shared.keyWindow?.topViewController() {
            topVC.present(alert, animated: true)
            result(true)
        } else {
            result(false)
        }
    }

    // Add state tracking
    private var viewStates: [String: [String: Any]] = [:]
    private var stateBindings: [String: Set<String>] = [:]
    
    private func handleStateChange(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String,
              let value = args["value"] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid state change args", details: nil))
            return
        }
        
        // Track which views need updates
        var updatedViews: Set<String> = []
        
        // Update state and find affected views
        for (viewId, states) in viewStates where states.keys.contains(key) {
            let oldValue = states[key]
            if !isEqual(oldValue, value) {
                viewStates[viewId]?[key] = value
                updatedViews.insert(viewId)
            }
        }
        
        // Include bound views
        if let boundViews = stateBindings[key] {
            updatedViews.formUnion(boundViews)
        }
        
        // Only update changed views
        for viewId in updatedViews {
            updateViewWithState(viewId: viewId, key: key, value: value)
        }
        
        result(true)
        
        // Notify Flutter about successful update
        methodChannel?.invokeMethod("onStateUpdateComplete", arguments: [
            "key": key,
            "value": value,
            "updatedViews": Array(updatedViews)
        ])
    }
    
    private func isEqual(_ lhs: Any?, _ rhs: Any?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return true
        case let (lhs as String, rhs as String): return lhs == rhs
        case let (lhs as Int, rhs as Int): return lhs == rhs
        case let (lhs as Double, rhs as Double): return lhs == rhs
        case let (lhs as Bool, rhs as Bool): return lhs == rhs
        default: return false
        }
    }
    
    private func updateViewWithState(viewId: String, key: String, value: Any) {
        guard let view = views[viewId] else { return }
        
        // Apply state update based on view type and state key
        switch view {
        case let label as UILabel:
            if key.hasSuffix("text") {
                label.text = "\(value)"
            } else if key.hasSuffix("color") {
                label.textColor = UIColor(named: "\(value)") ?? .black
            }
            
        case let button as UIButton:
            if key.hasSuffix("title") {
                button.setTitle("\(value)", for: .normal)
            } else if key.hasSuffix("enabled") {
                button.isEnabled = (value as? Bool) ?? true
            }
            
        case let textField as UITextField:
            if key.hasSuffix("text") {
                textField.text = "\(value)"
            } else if key.hasSuffix("placeholder") {
                textField.placeholder = "\(value)"
            }
            
        case let imageView as UIImageView:
            if key.hasSuffix("url"), let urlString = value as? String {
                loadImage(from: urlString, into: imageView)
            }
            
        default:
            // Common properties for all views
            if key.hasSuffix("backgroundColor"), let colorName = value as? String {
                view.backgroundColor = UIColor(named: colorName)
            } else if key.hasSuffix("alpha"), let opacity = value as? CGFloat {
                view.alpha = opacity
            } else if key.hasSuffix("hidden"), let isHidden = value as? Bool {
                view.isHidden = isHidden
            }
        }
    }
    
    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }.resume()
    }
    
    private func handleBindState(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let key = args["key"] as? String else {
            result(false)
            return
        }
        
        // Initialize state tracking for view if needed
        viewStates[viewId] = viewStates[viewId] ?? [:]
        
        // Add to state bindings
        stateBindings[key] = stateBindings[key] ?? Set()
        stateBindings[key]?.insert(viewId)
        
        result(true)
    }
    
    private func handleUnbindState(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let key = args["key"] as? String else {
            result(false)
            return
        }
        
        stateBindings[key]?.remove(viewId)
        viewStates[viewId]?.removeValue(forKey: key)
        
        result(true)
    }
}
