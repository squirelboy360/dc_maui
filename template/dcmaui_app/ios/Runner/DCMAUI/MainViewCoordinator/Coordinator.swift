//
//  Coordinator.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import Flutter
import UIKit

/// Main coordinator class for the DC MAUI Framework
/// Manages communication between Flutter and native iOS views
class DCViewCoordinator: NSObject, FlutterPlugin, FlutterStreamHandler {
    // MARK: - Properties
    
    // Method channel for communication with Dart side
    var methodChannel: FlutterMethodChannel?
    
    // Event sink for sending events to Dart
    private var eventSink: FlutterEventSink?
    
    // View registry for managing native views
    let viewRegistry = ViewRegistry()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        debugPrint("DC MAUI: Initializing DCViewCoordinator")
    }
    
    // MARK: - FlutterPlugin Implementation
    
    /// Handle method calls from the Flutter side
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint("DC MAUI: Received method call: \(call.method)")
        
        switch call.method {
        case "initialize":
            setupRootView()
            result(true)
            
        case "createRootContainer":
            setupRootView()
            result(true)
            
        case "createView":
            handleCreateView(call, result: result)
            
        case "updateView":
            handleUpdateView(call, result: result)
            
        case "deleteView":
            handleDeleteView(call, result: result)
            
        case "attachView":
            handleAttachView(call, result: result)
            
        case "setChildren":
            handleSetChildren(call, result: result)
            
        case "logViewTree":
            logViewTree(result)
            
        case "simulateEvent":
            handleSimulateEvent(call, result: result)
            
        case "addEventListeners":
            handleAddEventListeners(call, result: result)
            
        case "removeEventListeners":
            handleRemoveEventListeners(call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - FlutterStreamHandler Implementation
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        debugPrint("DC MAUI: Started listening for events")
        
        // Send initial event to confirm event channel is working
        sendEvent(viewId: "system", eventName: "nativeUIReady", params: ["timestamp": Date().timeIntervalSince1970 * 1000])
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        debugPrint("DC MAUI: Stopped listening for events")
        return nil
    }
    
    // MARK: - Event Handling
    
    /// Send event to Flutter side
    func sendEvent(viewId: String, eventName: String, params: [String: Any] = [:]) {
        guard let eventSink = eventSink else {
            debugPrint("DC MAUI: Error - tried to send event but no event sink available")
            return
        }
        
        var eventParams = params
        eventParams["target"] = viewId
        
        let event: [String: Any] = [
            "viewId": viewId,
            "eventName": eventName,
            "params": eventParams
        ]
        
        DispatchQueue.main.async {
            eventSink(event)
        }
    }
    
    // MARK: - Root View Setup
    
    /// Set up the root container view
    func setupRootView() {
        // Find the root view controller for our container
        guard let rootVC = findRootViewController() else {
            debugPrint("DC MAUI: ERROR - Could not find root view controller")
            return
        }
        
        // Create or find our root container view
        let containerView: UIView
        if let existingContainer = rootVC.view.viewWithTag(42042) {
            // Use existing container
            containerView = existingContainer
            debugPrint("DC MAUI: Found existing root container view")
        } else {
            // Create new container view
            containerView = UIView(frame: rootVC.view.bounds)
            containerView.tag = 42042
            containerView.backgroundColor = .clear
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            rootVC.view.addSubview(containerView)
            debugPrint("DC MAUI: Created new root container view")
        }
        
        // Register the container view
        let rootViewId = "root"
        viewRegistry.registerView(containerView, withId: rootViewId)
        
        // Send confirmation event
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sendEvent(
                viewId: "system", 
                eventName: "rootContainerReady",
                params: ["rootId": rootViewId]
            )
        }
    }
    
    /// Invoke a function from JS using its reference
    func callFunction(reference: [String: Any], params: [String: Any]) -> Any? {
        // This is a placeholder for function call handling
        debugPrint("DC MAUI: Function call not implemented")
        return nil
    }
    
    /// Render a view using a JS function reference
    func renderFunction(reference: [String: Any], params: [String: Any]) -> UIView? {
        // This is a placeholder for render function handling
        debugPrint("DC MAUI: Render function not implemented")
        return nil
    }
}
