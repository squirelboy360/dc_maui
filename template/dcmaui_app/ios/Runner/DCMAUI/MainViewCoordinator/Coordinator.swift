//
//  Coordinator.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 3/12/25.
//

import UIKit
import Flutter

@available(iOS 13.0, *)
class DCViewCoordinator: NSObject, FlutterPlugin, FlutterStreamHandler {
    internal var methodChannel: FlutterMethodChannel?
    internal var views: [String: UIView] = [:]
    internal var childViews: [String: [String]] = [:]
    private var rootViewId: String?
    private var rootView: UIView?
    var eventSink: FlutterEventSink?
    
    // MARK: - FlutterStreamHandler methods
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("DC MAUI: Event channel listener registered")
        eventSink = events
        
        // Notify Flutter that native UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.sendEvent(viewId: "system", eventName: "nativeUIReady", params: nil)
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("DC MAUI: Event channel listener cancelled")
        eventSink = nil
        return nil
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("Handling method: \(call.method) with args: \(String(describing: call.arguments))")
            
            switch call.method {
            case "createView":
                self.handleCreateView(call, result: result)
                
            case "attachView":
                guard let args = call.arguments as? [String: Any],
                      let parentId = args["parentId"] as? String,
                      let childId = args["childId"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing parentId or childId", details: nil))
                    return
                }
                
                let childArgs: [String: Any] = ["parentId": parentId, "childId": childId]
                self.handleAttachView(FlutterMethodCall(methodName: "attachView", arguments: childArgs), result: result)
                
            case "setChildren":
                print("Got setChildren with args: \(String(describing: call.arguments))")
                if let args = call.arguments as? [String: Any],
                   let parentId = args["parentId"] as? String,
                   let childrenIds = args["childIds"] as? [String] {
                    self.handleSetChildren(call, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing parentId or childrenIds", details: nil))
                }
                
            case "deleteView":
                self.handleDeleteView(call, result: result)
                
            case "updateView":
                self.handleUpdateView(call, result: result)
                
            case "initialize":
                // Handle initialization call from Flutter
                self.setupRootView()
                result(true)
                
            case "addEventListeners":
                self.handleAddEventListeners(call, result: result)
                
            case "removeEventListeners":
                self.handleRemoveEventListeners(call, result: result)
                
            case "logViewTree":
                // New handler for logging the view tree
                self.logViewTree(result)
                
            case "simulateEvent":
                // New handler for simulating events
                self.handleSimulateEvent(call, result: result)
                
            case "getViewInfo":
                self.handleGetViewInfo(call, result: result)
                
            case "resetViewRegistry":
                // Reset view registry for recovery after errors
                self.views.removeAll()
                self.childViews.removeAll()
                self.setupRootView() // Recreate root view
                result(true)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // Add these new methods
    private func logViewTree(_ result: @escaping FlutterResult) {
        // Create a string representation of the view hierarchy
        var treeDescription = "View Tree:\n"
        
        if let rootView = rootView {
            treeDescription += describeViewHierarchy(rootView, depth: 0)
        } else {
            treeDescription += "No root view found"
        }
        
        print(treeDescription)
        result(treeDescription)
    }
    
    private func describeViewHierarchy(_ view: UIView, depth: Int) -> String {
        let indent = String(repeating: "  ", count: depth)
        var description = "\(indent)- \(type(of: view))"
        
        if let dcView = view as? DCBaseView {
            description += " (ID: \(dcView.viewId))"
        }
        
        description += "\n"
        
        for subview in view.subviews {
            description += describeViewHierarchy(subview, depth: depth + 1)
        }
        
        return description
    }
    
    private func handleSimulateEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventName = args["eventName"] as? String,
              let data = args["data"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        // Send the event to Flutter
        sendEvent(viewId: viewId, eventName: eventName, params: data)
        result(true)
    }
    
    internal func setupRootView() {
        print("DC MAUI: Setting up root view")
        
        // Find the root view controller using newer API for iOS 13+
        let rootVC: UIViewController?
        if #available(iOS 13.0, *) {
            rootVC = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?.rootViewController
        } else {
            rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        }
        
        guard let rootVC = rootVC else {
            print("DC MAUI: ERROR - Could not find root view controller")
            return
        }
        
        print("DC MAUI: Found root view controller: \(type(of: rootVC))")
        
        // Create our root container view (if it doesn't already exist)
        if rootViewId == nil || rootView == nil {
            // Create our root container view with a specific frame
            let containerView = DCView(viewId: "root-container", props: [:])
            
            // Make it fill the entire screen
            containerView.translatesAutoresizingMaskIntoConstraints = false
            rootVC.view.addSubview(containerView)
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor),
                containerView.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor)
            ])
            
            // Add a debug background color if needed
            // containerView.backgroundColor = UIColor.systemBackground
            
            print("DC MAUI: Root container view added to hierarchy with frame: \(containerView.frame)")
            
            // Store the root view
            rootViewId = "root-container"
            rootView = containerView
            views[rootViewId!] = containerView
            childViews[rootViewId!] = []
            
            print("DC MAUI: Root view setup complete with ID: \(rootViewId!)")
            
            // Notify Flutter that native UI is ready immediately to speed up initialization
            DispatchQueue.main.async { [weak self] in
                self?.sendEvent(viewId: "system", eventName: "nativeUIReady", params: nil)
            }
        } else {
            print("DC MAUI: Root view already exists with ID: \(rootViewId!)")
        }
    }
    
    // Handle event listeners registration
    private func handleAddEventListeners(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventTypes = args["eventTypes"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        // In a real implementation, you'd register listeners for these event types
        // For now we'll just acknowledge the request
        result(true)
    }
    
    // Handle event listeners removal
    private func handleRemoveEventListeners(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventTypes = args["eventTypes"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        // In a real implementation, you'd unregister listeners for these event types
        // For now we'll just acknowledge the request
        result(true)
    }
    
    // Helper method to send an event back to Flutter
    func sendEvent(viewId: String, eventName: String, params: [String: Any]?) {
        var eventData: [String: Any] = [
            "viewId": viewId,
            "eventName": eventName
        ]
        
        if let params = params {
            eventData["params"] = params
        }
        
        // Use the event sink if available
        if let eventSink = eventSink {
            eventSink(eventData)
        } else {
            // Fallback to method channel if event sink is not available
            methodChannel?.invokeMethod("onNativeEvent", arguments: eventData)
        }
    }

    // New debug helper method
    internal func debugPrintViewHierarchy() {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            print("DC MAUI DEBUG: No root view controller found")
            return
        }
        
        print("DC MAUI DEBUG: ---- ROOT VIEW HIERARCHY ----")
        debugPrintView(rootVC.view, level: 0)
        print("DC MAUI DEBUG: ---- END OF HIERARCHY ----")
        
        // Print all registered views
        print("DC MAUI DEBUG: ---- REGISTERED VIEWS ----")
        for (viewId, view) in views {
            print("DC MAUI DEBUG: \(viewId): \(type(of: view)), frame: \(view.frame), hidden: \(view.isHidden), alpha: \(view.alpha)")
        }
        print("DC MAUI DEBUG: ---- END OF REGISTERED VIEWS ----")
    }
    
    private func debugPrintView(_ view: UIView, level: Int) {
        let indent = String(repeating: "  ", count: level)
        let viewType = type(of: view)
        let viewId = (view as? DCBaseView)?.viewId ?? "unknown"
        
        print("\(indent)- \(viewType) (frame: \(view.frame), alpha: \(view.alpha), hidden: \(view.isHidden), id: \(viewId))")
        
        for subview in view.subviews {
            debugPrintView(subview, level: level + 1)
        }
    }
}
