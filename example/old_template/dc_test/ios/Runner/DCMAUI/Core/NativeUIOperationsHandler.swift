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


@available(iOS 13.0, *)
class NativeUIOperationsHandler {
    // Reference to the manager that holds state
    private weak var manager: NativeUIManager?
    
    // State storage for views and global state
    private var viewStates: [String: [String: Any]] = [:]
    private var globalStates: [String: Any] = [:]
    private var stateConsumers: [String: [String]] = [:]  // Maps state keys to consuming view IDs
    private var eventListeners: [String: Bool] = [:]  // Store event listener registrations
    
    init(manager: NativeUIManager) {
        self.manager = manager
    }
    
    // MARK: - CRUD Operations
    
    // CREATE operation
    func handleCreateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let typeString = args["viewType"] as? String,
              let type = ViewType(rawValue: typeString),
              let properties = args["properties"] as? [String: Any],
              let manager = manager else {
            result(FlutterError(code: "INVALID_ARGS", message: "Failed to parse create view arguments", details: nil))
            return
        }
        
  
        
        let viewId = "\(type.rawValue)-\(UUID().uuidString)"
        
        let view = createComponent(ofType: type, withId: viewId, properties: properties)
        
//    
        
        print("Component type::\(type)  &&   viewId::\(viewId)")
        
        // Configure view for layout
        view.yoga.isEnabled = true
        
        // Initialize state if provided
        if let initialState = properties["initialState"] as? [String: Any] {
            viewStates[viewId] = initialState
            view.handleStateChange(initialState)
        }
        
        // Apply properties - first apply layout properties
        if let layout = properties["layout"] as? [String: Any] {
            view.yoga.applyFlexbox(layout)
            view.yoga.applySpacing(layout)
        }
        
        // Then apply style properties
        if let style = properties["style"] as? [String: Any] {
            view.applyStyle(style)
        }
        
        // Special handling for ScrollView
        if type == .scrollView {
            if let scrollView = view as? DCScrollView {
                // Apply scroll view specific style properties
                if let scrollViewStyle = properties["scrollViewStyle"] as? [String: Any] {
                    view.applyStyle(["scrollViewStyle": scrollViewStyle])
                }
            }
        }
        
        // Setup events if present
        if let events = properties["events"] as? [String: Any] {
            print("Setting up events for view: \(viewId)")
            print("Events config: \(events)")
            view.setupEvents(events, channel: manager.getMethodChannel())
        }
        
        manager.views[viewId] = view
        manager.childViews[viewId] = []
        
        // Handle children if provided (for container views)
        if let childrenIds = properties["children"] as? [String] {
            print("Processing \(childrenIds.count) children for \(viewId)")
            
            // Special handling for ScrollView 
            let isScrollView = view is DCScrollView
            
            for childId in childrenIds {
                if let childView = manager.views[childId] {
                    // If child is already attached to another parent, create a duplicate
                    if childView.superview != nil {
                        print("Child \(childId) already has a parent, creating duplicate")
                        let newId = "\(childId)-duplicate-\(UUID().uuidString)"
                        if let duplicateView = copyComponent(childView, withNewId: newId) {
                            manager.views[newId] = duplicateView
                            view.addSubview(duplicateView)
                            manager.childViews[viewId]?.append(newId)
                        }
                    } else {
                        // Child isn't attached yet, proceed normally
                        view.addSubview(childView)
                        manager.childViews[viewId]?.append(childId)
                    }
                }
            }
            
            // Force layout update after adding all children
            view.yoga.applyLayout(preservingOrigin: true)
            
            // Special handling for ScrollView content size adjustment
            if isScrollView {
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
        
        result(viewId)
    }
    
    // ATTACH operation (for parent-child relationships)
    func handleAttachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let manager = manager,
              let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String,
              let parentView = manager.views[parentId],
              let childView = manager.views[childId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid parent or child ID", details: nil))
            return
        }
        
        print("Attaching \(childId) to \(parentId)")
        
        // Check if child already has a parent
        if childView.superview != nil {
            print("Child \(childId) already has a parent, creating duplicate")
            let newId = "\(childId)-duplicate-\(UUID().uuidString)"
            if let duplicateView = copyComponent(childView, withNewId: newId) {
                manager.views[newId] = duplicateView
                parentView.addSubview(duplicateView)
                manager.childViews[parentId]?.append(newId)
                
                // Copy state for duplicated view
                if let state = viewStates[childId] {
                    viewStates[newId] = state
                    duplicateView.handleStateChange(state)
                }
                
                result(true)
                return
            }
        }
        
        // Handle specific behavior for ScrollView
        let isScrollViewParent = parentView is DCScrollView
        
        parentView.addSubview(childView)
        manager.childViews[parentId]?.append(childId)
        
        // Force layout update with special handling for ScrollView
        if isScrollViewParent {
            // For ScrollView, ensure proper content size calculation
            childView.yoga.applyLayout(preservingOrigin: true)
            childView.layoutIfNeeded()
            parentView.setNeedsLayout()
            parentView.layoutIfNeeded()
        } else {
            // Standard layout flow
            parentView.yoga.applyLayout(preservingOrigin: true)
            parentView.layoutIfNeeded()
        }
        
        result(true)
    }
    
    // DELETE operation
    func handleDeleteView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let manager = manager,
              let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = manager.views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view ID", details: nil))
            return
        }
        
        // Remove from parent's children list
        if let parentId = manager.views.first(where: { $0.value == view.superview })?.key {
            manager.childViews[parentId]?.removeAll { $0 == viewId }
        }
        
        // Special handling for ScrollView - may need to update content size
        if let parentView = view.superview as? DCScrollView {
            view.removeFromSuperview()
            parentView.setNeedsLayout()
            parentView.layoutIfNeeded()
        } else {
            view.removeFromSuperview()
        }
        
        // Remove view and its references
        manager.views.removeValue(forKey: viewId)
        manager.childViews.removeValue(forKey: viewId)
        
        // Clean up state references
        viewStates.removeValue(forKey: viewId)
        
        // Remove this view ID from state consumers
        for (stateKey, viewIds) in stateConsumers {
            stateConsumers[stateKey] = viewIds.filter { $0 != viewId }
        }
        
        result(true)
    }
    
    // GET ROOT VIEW operation
    func handleGetRootView(result: @escaping FlutterResult) {
        guard let manager = manager,
              let rootViewId = manager.getRootViewId(),
              let rootView = manager.views[rootViewId] else {
            // If no root view exists, create one
            manager?.setupRootView()
            
            // Retry after setup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.handleGetRootView(result: result)
            }
            return
        }
        
        result([
            "viewId": rootViewId,
            "width": rootView.frame.width,
            "height": rootView.frame.height
        ])
    }
    
    // MARK: - State Management
    
    // SET STATE operation (global state change)
    func handleSetState(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let stateKey = args["stateKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid state arguments", details: nil))
            return
        }
        
        // Store the new state value
        let value = args["value"]
        globalStates[stateKey] = value
        
        // Find all views consuming this state and update them
        if let consumers = stateConsumers[stateKey] {
            for viewId in consumers {
                if let view = manager?.views[viewId] {
                    // Create or update the view's state
                    var viewState = viewStates[viewId] ?? [:]
                    viewState[stateKey] = value
                    viewStates[viewId] = viewState
                    
                    // Apply the state change to the view
                    view.handleStateChange([stateKey: value])
                    
                    // Mark for layout update
                    view.setNeedsLayout()
                }
            }
        }
        
        // Notify observers about the state change
        notifyStateObservers(stateKey, value as Any)
        
        result(true)
    }
    
    // UPDATE VIEW STATE operation (per-view state update)
    func handleUpdateViewState(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let state = args["state"] as? [String: Any],
              let view = manager?.views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view state update arguments", details: nil))
            return
        }
        
        // Update the view's state store
        var currentState = viewStates[viewId] ?? [:]
        for (key, value) in state {
            currentState[key] = value
        }
        viewStates[viewId] = currentState
        
        // Apply the state changes to the view
        view.handleStateChange(state)
        
        // Special handling for ScrollView state updates
        if view is DCScrollView {
            // Ensure proper layout for scroll view state changes
            view.setNeedsLayout()
            view.layoutIfNeeded()
        } else {
            // Force layout update if needed
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        
        result(true)
    }
    
    // Register a view as consumer of state
    func registerStateConsumer(viewId: String, stateKey: String) {
        var consumers = stateConsumers[stateKey] ?? []
        if !consumers.contains(viewId) {
            consumers.append(viewId)
            stateConsumers[stateKey] = consumers
            
            // Apply current state value if available
            if let value = globalStates[stateKey] {
                var viewState = viewStates[viewId] ?? [:]
                viewState[stateKey] = value
                viewStates[viewId] = viewState
                
                if let view = manager?.views[viewId] {
                    view.handleStateChange([stateKey: value])
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
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
        case .scrollView:
            return DCScrollView(viewId: id)
        case .listView:
            return DCListView(viewId: id)
        case .textInput:
            return DCTextInput(viewId: id)
        case .touchableOpacity:
            return DCTouchable(viewId: id)
        default:
            return DCView(viewId: id)
        }
    }
    
    private func copyComponent(_ originalView: DCView, withNewId newId: String) -> DCView? {
        guard let manager = manager else { return nil }
        let properties = getViewProperties(originalView)
        
        // Safe dictionary access
        let viewTypeString = originalView.viewId.split(separator: "-").first.map(String.init) ?? ""
        guard let type = ViewType(rawValue: viewTypeString) else { return nil }
        
        let newView = createComponent(ofType: type, withId: newId, properties: properties)
        
        // Copy yoga layout properties
        if let yogaConfig = properties["layout"] as? [String: Any] {
            newView.yoga.applyFlexbox(yogaConfig)
            newView.yoga.applySpacing(yogaConfig)
        }
        
        // Copy state
        if let state = viewStates[originalView.viewId] {
            viewStates[newId] = state
            newView.handleStateChange(state)
        }
        
        // Copy component specific properties
        if let originalScrollView = originalView as? DCScrollView, 
           let newScrollView = newView as? DCScrollView,
           let scrollViewStyle = properties["scrollViewStyle"] as? [String: Any] {
            newScrollView.applyStyle(["scrollViewStyle": scrollViewStyle])
        }
        
        // Setup events if needed
        if let channel = manager.getMethodChannel() {
            let events = properties["events"] as? [String: Any] ?? [:]
            newView.setupEvents(events, channel: channel)
        }
        
        return newView
    }
    
    private func getViewProperties(_ view: DCView) -> [String: Any] {
        var properties: [String: Any] = [:]
        
        // Get specific properties from various view types
        if let textView = view as? DCText {
            properties["text"] = textView.getText()
        }
        
        // Get scroll view properties
        if let scrollView = view as? DCScrollView {
            // Capture scroll view specific properties
            let scrollViewState = scrollView.captureCurrentState()
            var scrollViewStyle: [String: Any] = [:]
            
            // Extract scroll-specific properties from state
            if let showsIndicators = scrollViewState["showsIndicators"] as? Bool {
                scrollViewStyle["showsIndicators"] = showsIndicators
            }
            if let bounces = scrollViewState["bounces"] as? Bool {
                scrollViewStyle["bounces"] = bounces
            }
            if let direction = scrollViewState["direction"] as? String {
                scrollViewStyle["direction"] = direction
            }
            if let contentOffset = scrollViewState["contentOffset"] as? [String: Any] {
                if let y = contentOffset["y"] as? CGFloat {
                    scrollViewStyle["initialScrollY"] = y
                }
                if let x = contentOffset["x"] as? CGFloat {
                    scrollViewStyle["initialScrollX"] = x
                }
            }
            
            if !scrollViewStyle.isEmpty {
                properties["scrollViewStyle"] = scrollViewStyle
            }
        }
        
        // Add other common properties
        if let backgroundColor = view.backgroundColor {
            properties["backgroundColor"] = backgroundColor.toARGB32()
        }
        
        // Include state in properties
        if let state = viewStates[view.viewId] {
            properties["state"] = state
        }
        
        // Capture additional state from the component
        let componentState = view.captureCurrentState()
        for (key, value) in componentState {
            properties[key] = value
        }
        
        return properties
    }
    
    // MARK: - Additional Methods for View Operations
    
    // Add the getState method to retrieve view state
    func handleGetState(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let keys = args["keys"] as? [String],
              let view = manager?.views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for getState", details: nil))
            return
        }
        
        // Get current state for requested keys
        var stateValues: [String: Any] = [:]
        let currentState = viewStates[viewId] ?? [:]
        
        for key in keys {
            if let value = currentState[key] {
                stateValues[key] = value
            }
        }
        
        result(stateValues)
    }

    // Add getChildrenIds method
    func handleGetChildrenIds(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view ID", details: nil))
            return
        }
        
        if let childIds = manager?.childViews[viewId] {
            result(childIds)
        } else {
            result([])
        }
    }

    // Add detachView method
    func handleDetachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let manager = manager,
              let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String,
              let parentView = manager.views[parentId],
              let childView = manager.views[childId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid parent or child ID", details: nil))
            return
        }
        
        // Remove child from parent
        childView.removeFromSuperview()
        
        // Update child tracking
        if var children = manager.childViews[parentId] {
            children.removeAll { $0 == childId }
            manager.childViews[parentId] = children
        }
        
        // Special handling for scroll view parent
        if parentView is DCScrollView {
            parentView.setNeedsLayout()
            parentView.layoutIfNeeded()
        }
        
        result(true)
    }

    // Add addEventListener method
    func handleAddEventListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventType = args["eventType"] as? String,
              let view = manager?.views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for addEventListener", details: nil))
            return
        }
        
        // Store event listener registration
        let eventKey = "\(viewId)_\(eventType)"
        eventListeners[eventKey] = true
        
        result(true)
    }

    // Add the proper state notification mechanism
    private func notifyStateObservers(_ stateKey: String, _ value: Any) {
        guard let channel = manager?.getMethodChannel() else { return }
        
        // Notify Dart side of state change
        channel.invokeMethod("onStateChange", arguments: [
            "stateKey": stateKey,
            "value": value
        ])
    }

    // Handle specific methods for ListView
    func handleSetItem(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let listViewId = args["listViewId"] as? String,
              let index = args["index"] as? Int,
              let itemId = args["itemId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for setItem", details: nil))
            return
        }
        
        guard let listView = manager?.views[listViewId] as? DCListView,
              let itemView = manager?.views[itemId] else {
            let viewExists = manager?.views[listViewId] != nil
            let itemExists = manager?.views[itemId] != nil
            
            // More detailed error for debugging
            result(FlutterError(
                code: "INVALID_VIEW", 
                message: "ListView or item view not found. ListView exists: \(viewExists), Item exists: \(itemExists)",
                details: "ListView ID: \(listViewId), Item ID: \(itemId)"
            ))
            return
        }
        
        print("Setting item at index \(index) with ID \(itemId) in ListView \(listViewId)")
        
        // Get optional key
        let key = args["key"] as? String
        
        // Set the item in the list view - optimized for virtualization
        listView.setItem(index, itemView: itemView, key: key)
        result(true)
    }

    func handleScrollToIndex(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let listViewId = args["listViewId"] as? String,
              let index = args["index"] as? Int,
              let listView = manager?.views[listViewId] as? DCListView else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for scrollToIndex", details: nil))
            return
        }
        
        let animated = args["animated"] as? Bool ?? true
        listView.scrollToIndex(index, animated: animated)
        result(true)
    }

    func handleRefreshData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let listViewId = args["listViewId"] as? String,
              let dataLength = args["dataLength"] as? Int,
              let listView = manager?.views[listViewId] as? DCListView else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for refreshData", details: nil))
            return
        }
        
        // Update the data length property
        listView.handleStateChange(["dataLength": dataLength])
        
        // Remove all existing items - optimized for virtualization
        listView.removeAllItems()
        
        result(true)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch call.method {
            case "createView":
                self.handleCreateView(call, result: result)
                
            case "attachView":
                self.handleAttachView(call, result: result)
                
            case "detachView":
                self.handleDetachView(call, result: result)
                
            case "deleteView":
                self.handleDeleteView(call, result: result)
                
            case "getRootView":
                self.handleGetRootView(result: result)
                
            case "setState":
                self.handleSetState(call, result: result)
                
            case "updateViewState":
                self.handleUpdateViewState(call, result: result)
                
            case "getState":
                self.handleGetState(call, result: result)
                
            case "getChildrenIds":
                self.handleGetChildrenIds(call, result: result)
                
            case "addEventListener":
                self.handleAddEventListener(call, result: result)

            // Add new ListView-specific methods
            case "setItem":
                self.handleSetItem(call, result: result)
                
            case "scrollToIndex":
                self.handleScrollToIndex(call, result: result)
                
            case "refreshData":
                self.handleRefreshData(call, result: result)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
