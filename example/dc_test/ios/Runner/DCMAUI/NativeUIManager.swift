import UIKit
import Flutter

@available(iOS 13.0, *)
class NativeUIManager: NSObject, FlutterPlugin {
    private var methodChannel: FlutterMethodChannel?
    private var views: [String: UIView] = [:]
    private var childViews: [String: [String]] = [:]
    private var rootViewId: String?
    private var window: UIWindow?
    private var registeredGestureRecognizers: [String: [UIGestureRecognizer]] = [:]
    
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
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Create a new window with the correct frame
            window = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window?.windowScene = windowScene
            
            // Create root view controller
            let rootVC = UIViewController()
            rootVC.view.backgroundColor = .white
            
            // Create root view with proper frame
            let rootView = UIView(frame: rootVC.view.bounds)
            rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            rootView.backgroundColor = .white
            rootVC.view.addSubview(rootView)
            
            // Set up window
            rootViewId = "root-\(UUID().uuidString)"
            views[rootViewId!] = rootView
            childViews[rootViewId!] = []
            
            window?.rootViewController = rootVC
            window?.makeKeyAndVisible()
            
            // Hide Flutter view by finding the FlutterViewController
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
               let flutterVC = keyWindow.rootViewController as? FlutterViewController {
                flutterVC.view.isHidden = true
            }
            
            // Log success
            print("Native UI window setup complete with root view: \(rootViewId!)")
        }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
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
           case "StackView":
               let stackView = UIStackView()
               stackView.axis = .vertical
               stackView.spacing = 20
               stackView.alignment = .center
               stackView.distribution = .equalSpacing
               stackView.backgroundColor = .clear
               view = stackView
               
           case "Button":
               let button = UIButton(type: .system)
               button.setTitle(args["title"] as? String ?? "Button", for: .normal)
               button.backgroundColor = .systemBlue
               button.setTitleColor(.white, for: .normal)
               button.layer.cornerRadius = 8
               button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
               view = button
               
           case "Label":
               let label = UILabel()
               label.text = args["text"] as? String ?? ""
               label.textAlignment = .center
               label.numberOfLines = 0
               label.font = .systemFont(ofSize: 17)
               view = label
               
           default:
               view = UIView()
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
                
                // Ensure we're on the main thread when sending events
                DispatchQueue.main.async { [weak self] in
                    self?.methodChannel?.invokeMethod("onNativeEvent", arguments: eventData) { result in
                        // Handle completion if needed
                        if let error = result as? FlutterError {
                            print("Error sending event to Flutter: \(error)")
                        }
                    }
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
