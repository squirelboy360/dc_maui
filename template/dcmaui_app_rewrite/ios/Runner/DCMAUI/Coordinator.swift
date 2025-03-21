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
    
    // Root view controller reference
    var rootViewController: UIViewController?
    
    // Shared instance for static access - REMOVED DUPLICATE
    // Using the implementation from Coordinator+Shared.swift
    
    // MARK: - FlutterPlugin Registration - REMOVED DUPLICATE
    // Using the implementation from Coordinator+Shared.swift
    
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
            
        case "ping":
            // Simple ping to check if the bridge is responsive
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }


          /// Set up the root container view
    func setupRootView() {
        // Find the root view controller for our container
        guard let rootVC = rootViewController ?? findRootViewController() else {
            debugPrint("DC MAUI: ERROR - Could not find root view controller")
            return
        }
        
        // Store root view controller for later use
        if rootViewController == nil {
            rootViewController = rootVC
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
            debugPrint("DC MAUI: Created new root container view with frame: \(containerView.frame)")
        }
        
        // Add debug identifier
        containerView.accessibilityIdentifier = "DCMAUIRootContainer"
        
        // Register the container view
        let rootViewId = "root"
        viewRegistry.registerView(containerView, withId: rootViewId)
        
        // Check for existing view_0 that might need to be added
        if let view0 = viewRegistry.getView("view_0") {
            // Add it to container if not already there
            if view0.superview == nil {
                containerView.addSubview(view0)
                view0.frame = containerView.bounds
                debugPrint("DC MAUI: Added previously created view_0 to root container")
            }
        }
        
    }
    
    