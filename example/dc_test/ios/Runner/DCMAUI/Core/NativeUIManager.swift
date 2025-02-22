/*
 BSD 3-Clause License

Copyright (c) 2025, Tahiru Agbanwa

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
        
        // Create native window immediately
        // Initialize after a brief delay to ensure Flutter is ready
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  instance.setupRootView()
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
        print("arguments: \(args)");
        print()
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
        if let properties = args["properties"] as? [String: Any],
           let events = properties["events"] as? [String: Any] {
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
        let properties = getViewProperties(originalView)
        
        // Safe dictionary access
        let viewTypeString = originalView.viewId.split(separator: "-").first.map(String.init) ?? ""
        guard let type = ViewType(rawValue: viewTypeString) else { return nil }
        
        let newView = createComponent(ofType: type, withId: newId, properties: properties)
        
        // Copy yoga layout properties
        if let yogaConfig = properties["layout"] as? [String: Any] {
            newView.yoga.applyFlexbox(yogaConfig)
            newView.yoga.applySpacing(yogaConfig)
            
            print("parsed layout config: \(yogaConfig)")
        }
        
        
        
        newView.handleStateChange(properties)
        
        if let channel = self.methodChannel {
            let events = properties["events"] as? [String: Any] ?? [:]
            newView.setupEvents(events, channel: channel)
        }
        
        return newView
    }
    
    private func getViewProperties(_ view: DCView) -> [String: Any] {
        var properties: [String: Any] = [:]
        
        if let textView = view as? DCText {
            properties["text"] = textView.getText()
        }
        
        if let imageView = view as? DCImage {
            if let image = imageView.getImage() {
                properties["image"] = image
            }
        }
        
        // Add other properties as needed
        if let backgroundColor = view.backgroundColor {
            properties["backgroundColor"] = backgroundColor.toARGB32()
        }
        
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
        if let rootViewId = self.rootViewId,
           let rootView = views[rootViewId] {
            result([
                "viewId": rootViewId,
                "width": rootView.frame.width,
                "height": rootView.frame.height
            ])
        } else {
            // If no root view exists, create one
            setupRootView()
            handleGetRootView(result: result) // Retry after setup
        }
    }

    private func setupRootView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            
            // Create a separate window for native UI
            let nativeWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
            nativeWindow.windowScene = windowScene
            
            // Create root view controller
            let rootVC = UIViewController()
            
            rootVC.view.backgroundColor = .blue
            
            // Create and configure root view
            let rootView = DCView(viewId: "root")
            rootView.frame = rootVC.view.bounds
            rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            rootView.yoga.isEnabled = true
            rootView.yoga.flexDirection = .column
            
            // Set up view hierarchy
            rootVC.view.addSubview(rootView)
            nativeWindow.rootViewController = rootVC
            nativeWindow.makeKeyAndVisible()
            
            // Store references
            self.window = nativeWindow
            self.rootViewId = rootView.viewId
            self.views[rootView.viewId] = rootView
            self.childViews[rootView.viewId] = []
        }
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    func cleanup() {
        views.values.forEach { $0.removeFromSuperview() }
        views.removeAll()
        childViews.removeAll()
        rootViewId = nil
        window = nil
        methodChannel = nil
    }
}

// Add to ViewType enum
extension ViewType {
    init?(fromViewId viewId: String) {
        let baseType = viewId.split(separator: "-")[0]
        self.init(rawValue: String(baseType))
    }
}
