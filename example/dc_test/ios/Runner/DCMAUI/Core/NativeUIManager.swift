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
              let type = ViewType(rawValue: typeString),
              let properties = args["properties"] as? [String: Any] else {
            print("Failed to parse create view arguments")
            return
        }
        
        print("Creating view: \(typeString)")
        print("Properties: \(properties)")
        
        let viewId = "\(type.rawValue)-\(UUID().uuidString)"
        let view = createComponent(ofType: type, withId: viewId, properties: properties)
        
        // Configure view for layout
        view.yoga.isEnabled = true
        
        // Apply properties
        if let layout = properties["layout"] as? [String: Any] {
            view.yoga.applyFlexbox(layout)
            view.yoga.applySpacing(layout)
        }
        
        if let style = properties["style"] as? [String: Any] {
            view.applyStyle(style)
        }
        
        // Setup events if present
        if let events = properties["events"] as? [String: Any] {
            print("Setting up events for view: \(viewId)")
            print("Events config: \(events)")
            view.setupEvents(events, channel: methodChannel)
        }
        
        views[viewId] = view
        childViews[viewId] = []
        
        // Handle children if provided (for ScrollView, ListView, etc.)
        if let childrenIds = properties["children"] as? [String] {
            print("Processing \(childrenIds.count) children for \(viewId)")
            
            // For ScrollView, handle children differently
            if type == .scrollView, let scrollView = view as? DCScrollView {
                print("Adding children to ScrollView: \(viewId)")
                
                for childId in childrenIds {
                    if let childView = views[childId] {
                        if childView.superview != nil {
                            print("Child \(childId) already has a parent, creating duplicate")
                            let newId = "\(childId)-duplicate-\(UUID().uuidString)"
                            if let duplicateView = copyComponent(childView, withNewId: newId) {
                                views[newId] = duplicateView
                                duplicateView.frame = CGRect(x: 0, y: 0, width: 200, height: 100) // Set initial frame
                                scrollView.addSubview(duplicateView)
                                childViews[viewId]?.append(newId)
                                print("Added duplicate \(newId) to ScrollView")
                            }
                        } else {
                            // Set initial frame before adding to ensure visibility
                            childView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
                            scrollView.addSubview(childView)
                            childViews[viewId]?.append(childId)
                            print("Added child \(childId) to ScrollView")
                        }
                    } else {
                        print("Child \(childId) not found in views dictionary")
                    }
                }
                
                // Force layout after adding all children
                scrollView.setNeedsLayout()
                scrollView.layoutIfNeeded()
            } else {
                // Handle other view types normally
                for childId in childrenIds {
                    if let childView = views[childId] {
                        // If child is already attached to another parent, create a duplicate
                        if childView.superview != nil {
                            print("Child \(childId) already has a parent, creating duplicate")
                            let newId = "\(childId)-duplicate-\(UUID().uuidString)"
                            if let duplicateView = copyComponent(childView, withNewId: newId) {
                                views[newId] = duplicateView
                                view.addSubview(duplicateView)
                                childViews[viewId]?.append(newId)
                            }
                        } else {
                            // Child isn't attached yet, proceed normally
                            view.addSubview(childView)
                            childViews[viewId]?.append(childId)
                        }
                    }
                }
                // Force layout update after adding all children
                view.yoga.applyLayout(preservingOrigin: true)
            }
        }
        
        result(viewId)
    }
    
    private func createComponent(ofType type: ViewType, withId id: String, properties: [String: Any]) -> DCView {
        switch type {
        case .view:
            return DCView(viewId: id)
        case .label:
            // Initialize with empty text first
            let textView = DCText(viewId: id, text: "")
            // Apply text style immediately
            if let textStyle = properties["textStyle"] as? [String: Any] {
                textView.applyStyle(["textStyle": textStyle])
            }
            return textView
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
              let parentView = views[parentId],
              let childView = views[childId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid parent or child ID", details: nil))
            return
        }
        
        print("Attaching \(childId) to \(parentId)")
        
        // Check if child already has a parent
        if childView.superview != nil {
            print("Child \(childId) already has a parent, creating duplicate")
            let newId = "\(childId)-duplicate-\(UUID().uuidString)"
            if let duplicateView = copyComponent(childView, withNewId: newId) {
                views[newId] = duplicateView
                parentView.addSubview(duplicateView)
                childViews[parentId]?.append(newId)
                result(true)
                return
            }
        }
        
        parentView.addSubview(childView)
        childViews[parentId]?.append(childId)
        
        // Force layout update
        parentView.yoga.applyLayout(preservingOrigin: true)
        parentView.layoutIfNeeded()
        
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
        print("Setting up root view")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let nativeWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
            nativeWindow.windowScene = windowScene
            
            let rootVC = UIViewController()
            rootVC.view.backgroundColor = .blue.withAlphaComponent(0.2) // Debug color
            
            // Create root view with explicit frame and yoga config
            let rootView = DCView(viewId: "root")
            rootView.frame = rootVC.view.bounds
            rootView.backgroundColor = .clear
            rootView.yoga.isEnabled = true
            rootView.yoga.flexDirection = .column
            rootView.yoga.width = YGValue(value: Float(rootVC.view.bounds.width), unit: .point)
            rootView.yoga.height = YGValue(value: Float(rootVC.view.bounds.height), unit: .point)
            
            print("Root view frame: \(rootView.frame)")
            
            rootVC.view.addSubview(rootView)
            nativeWindow.rootViewController = rootVC
            nativeWindow.makeKeyAndVisible()
            
            self.window = nativeWindow
            self.rootViewId = rootView.viewId
            self.views[rootView.viewId] = rootView
            self.childViews[rootView.viewId] = []
            
            print("Root view setup complete with ID: \(rootView.viewId)")
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
