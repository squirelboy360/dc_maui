//
//  Coordinator.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 3/12/25.
//

import UIKit
import Flutter

public class DCViewCoordinator: NSObject, FlutterPlugin {
    static var shared: DCViewCoordinator?
    var methodChannel: FlutterMethodChannel?
    var eventChannel: FlutterEventChannel?
    var eventSink: FlutterEventSink?
    
    // Root view for the native UI hierarchy
    var rootView: UIView?
    var rootViewController: UIViewController?
    
    // Single source of truth - the ViewRegistry
    let viewRegistry = ViewRegistry()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let coordinator = DCViewCoordinator()
        coordinator.methodChannel = FlutterMethodChannel(
            name: "com.dcmaui.framework/view_coordinator",
            binaryMessenger: registrar.messenger()
        )
        
        coordinator.eventChannel = FlutterEventChannel(
            name: "com.dcmaui.framework/events",
            binaryMessenger: registrar.messenger()
        )
        
        registrar.addMethodCallDelegate(coordinator, channel: coordinator.methodChannel!)
        coordinator.eventChannel?.setStreamHandler(coordinator)
        shared = coordinator
        
        // Find the root view controller to use for showing our native UI
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            coordinator.rootViewController = rootController
            
            // Create a container view for our native UI
            let containerView = UIView(frame: rootController.view.bounds)
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            rootController.view.addSubview(containerView)
            
            coordinator.rootView = containerView
            print("DCViewCoordinator: Successfully added container view to root view controller")
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("DCViewCoordinator: Received method call: \(call.method)")
        
        // Handle various method calls
        switch call.method {
        case "createView":
            handleCreateView(call, result: result)
        case "updateView":
            handleUpdateView(call, result: result)
        case "deleteView":
            handleDeleteView(call, result: result)
        case "attachView":
            handleAttachView(call, result: result)
        case "detachView":
            handleDetachView(call, result: result)
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
    
    // Send events back to Flutter
    func sendEvent(viewId: String, eventName: String, params: [String: Any]) {
        guard let eventSink = eventSink else {
            print("DCViewCoordinator: No event sink available")
            return
        }
        
        let event: [String: Any] = [
            "viewId": viewId,
            "eventName": eventName,
            "params": params
        ]
        
        eventSink(event)
    }
}

// MARK: - FlutterStreamHandler protocol implementation
extension DCViewCoordinator: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
