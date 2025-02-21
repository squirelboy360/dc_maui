import UIKit
import Flutter
import YogaKit

enum ViewType: String {
    case view = "View"
    case label = "Label"
    case button = "Button"
    case image = "Image"
    case scrollView = "ScrollView"
    case textInput = "TextInput"
    case touchableOpacity = "TouchableOpacity"
    case listView = "ListView"
    case animatedView = "AnimatedView"
    case safeAreaView = "SafeAreaView"
}

@available(iOS 13.0, *)
class NativeUIManager: NSObject, FlutterPlugin {
    private var methodChannel: FlutterMethodChannel?
    internal var views: [String: DCView] = [:]
    internal var childViews: [String: [String]] = [:]
    private var rootViewId: String?
    private var window: UIWindow?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeUIManager()
        let channel = FlutterMethodChannel(
            name: "com.dcmaui.framework",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.methodChannel = channel
        
        instance.setupRootView()
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
            case "getRootView":
                self.handleGetRootView(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleCreateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let typeString = args["viewType"] as? String,
              let type = ViewType(rawValue: typeString) else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view type", details: nil))
            return
        }
        
        let viewId = "\(type.rawValue)-\(UUID().uuidString)"
        let view = createComponent(ofType: type, withId: viewId, properties: args["properties"] as? [String: Any] ?? [:])
        
        // Apply initial layout if provided
        if let layout = args["layout"] as? [String: Any] {
            view.applyStyle(layout)
        }
        
        // Apply initial style if provided
        if let style = args["style"] as? [String: Any] {
            view.applyStyle(style)
        }
        
        // Handle events if provided in properties
        if let events = args["properties"]?["events"] as? [String: Any] {
            view.setupEvents(events, channel: methodChannel)
        }
        
        views[viewId] = view
        childViews[viewId] = []
        
        result(viewId)
    }
    
    private func createComponent(ofType type: ViewType, withId id: String, properties: [String: Any]) -> DCView {
        switch type {
        case .view:
            return DCView(viewId: id)
        case .label:
            return DCText(viewId: id, text: properties["text"] as? String ?? "")
        case .button:
            return DCButton(viewId: id)
        case .image:
            return DCImage(viewId: id)
        case .scrollView:
            return DCScrollView(viewId: id)
        case .textInput:
            return DCTextInput(viewId: id)
        case .touchableOpacity:
            return DCTouchable(viewId: id)
        case .listView:
            return DCListView(viewId: id)
        case .animatedView:
            return DCAnimatedView(viewId: id)
        case .safeAreaView:
            return DCSafeAreaView(viewId: id)
        }
    }
    
    // Attach view to parent
    private func handleAttachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String,
              let parentView = views[parentId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid parent or child ID", details: nil))
            return
        }
        
        // Check if view is already attached somewhere
        if let childView = views[childId],
           childView.superview != nil {
            // Create a copy if duplicate flag is true, otherwise error
            if args["duplicate"] as? Bool == true {
                let newChildId = "\(childId)-copy-\(UUID().uuidString)"
                guard let copiedView = copyComponent(childView, withNewId: newChildId) else {
                    result(FlutterError(code: "COPY_FAILED", message: "Failed to copy component", details: nil))
                    return
                }
                
                views[newChildId] = copiedView
                childViews[newChildId] = []
                
                parentView.addSubview(copiedView)
                childViews[parentId]?.append(newChildId)
                
                // Trigger layout calculation
                parentView.yoga.applyLayout(preservingOrigin: true)
                result(newChildId) // Return new ID so dart side can track it
                return
            } else {
                result(FlutterError(code: "ALREADY_ATTACHED", message: "View is already attached. Use duplicate: true to create a copy", details: nil))
                return
            }
        }
        
        // Normal attachment for unattached views
        guard let childView = views[childId] else {
            result(FlutterError(code: "INVALID_VIEW", message: "Child view not found", details: nil))
            return
        }
        
        parentView.addSubview(childView)
        childViews[parentId]?.append(childId)
        
        // Trigger layout calculation
        parentView.yoga.applyLayout(preservingOrigin: true)
        result(true)
    }
    
    private func copyComponent(_ originalView: DCView, withNewId newId: String) -> DCView? {
        // Get original properties
        let properties = getViewProperties(originalView)
        
        // Create new component of same type
        let type = ViewType(rawValue: String(originalView.viewId.split(separator: "-")[0]))!
        let newView = createComponent(ofType: type, withId: newId, properties: properties)
        
        // Copy layout and style
        if let layout = originalView.yoga.toJSON() {
            newView.applyStyle(layout)
        }
        
        // Copy state if component supports it
        newView.handleStateChange(properties)
        
        // Copy events
        if let channel = self.methodChannel {
            newView.setupEvents(properties["events"] as? [String: Any] ?? [:], channel: channel)
        }
        
        return newView
    }
    
    private func getViewProperties(_ view: DCView) -> [String: Any] {
        var properties: [String: Any] = [:]
        
        // Capture basic properties
        if let text = (view as? DCText)?.text {
            properties["text"] = text
        }
        
        if let image = (view as? DCImage)?.imageView.image {
            properties["image"] = image
        }
        
        // Capture style properties
        if let backgroundColor = view.backgroundColor {
            properties["backgroundColor"] = backgroundColor
        }
        
        // Add other properties as needed...
        
        return properties
    }
    
    // Delete view and its children
    private func handleDeleteView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view ID", details: nil))
            return
        }
        
        // Remove from parent's children list
        if let parentId = views.first(where: { $0.value == view.superview })?.key {
            childViews[parentId]?.removeAll { $0 == viewId }
        }
        
        // Remove view and its references
        view.removeFromSuperview()
        views.removeValue(forKey: viewId)
        childViews.removeValue(forKey: viewId)
        
        result(true)
    }
    
    // Get root view info
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
}

@available(iOS 13.0, *)
extension NativeUIManager {
    func cleanup() {
        // Clear all views
        views.values.forEach { view in
            view.removeFromSuperview()
        }
        views.removeAll()
        childViews.removeAll()
        
        // Clear root
        rootViewId = nil
        
        // Release window if needed
        window = nil
        
        // Clear method channel
        methodChannel = nil
    }
    
    deinit {
        cleanup()
    }
}

// Add to ViewType enum
extension ViewType {
    init?(fromViewId viewId: String) {
        let baseType = viewId.split(separator: "-")[0]
        self.init(rawValue: String(baseType))
    }
}
