//
//  Handlers.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 3/13/25.
//

import UIKit
import Flutter


extension DCViewCoordinator {
    internal func handleCreateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let viewType = args["viewType"] as? String,
              let props = args["props"] as? [String: Any] else {
            print("DC MAUI: ERROR - Invalid arguments for createView: \(String(describing: call.arguments))")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        print("DC MAUI: Creating view of type \(viewType) with ID \(viewId)")
        
        // Create the appropriate view based on viewType
        let view = ViewFactory.createView(viewType: viewType, viewId: viewId, props: props)
        
        if let view = view {
            // Store the view in our dictionary
            views[viewId] = view
            
            // Initialize an empty children array for this view
            childViews[viewId] = []
            
            // Return success
            print("DC MAUI: Successfully created view \(viewId)")
            result(true)
        } else {
            print("DC MAUI: ERROR - Failed to create view of type \(viewType)")
            result(FlutterError(code: "VIEW_CREATION_FAILED", message: "Failed to create view of type \(viewType)", details: nil))
        }
    }
    
    internal func handleAttachView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let parentId = args["parentId"] as? String,
              let childId = args["childId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing parentId or childId", details: nil))
            return
        }
        
        guard let parentView = views[parentId], let childView = views[childId] else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "Parent or child view not found", details: nil))
            return
        }
        
        // Add child view to parent
        parentView.addSubview(childView)
        
        // Update our parent-child relationships
        if var children = childViews[parentId] {
            children.append(childId)
            childViews[parentId] = children
        } else {
            childViews[parentId] = [childId]
        }
        
        result(true)
    }
    
    internal func handleDeleteView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing viewId", details: nil))
            return
        }
        
        guard let view = views[viewId] else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found: \(viewId)", details: nil))
            return
        }
        
        // Recursively remove all child views first
        if let children = childViews[viewId], !children.isEmpty {
            for childId in children {
                let childArgs: [String: Any] = ["viewId": childId]
                handleDeleteView(FlutterMethodCall(methodName: "deleteView", arguments: childArgs), result: { _ in })
            }
        }
        
        // Remove the view from its parent
        view.removeFromSuperview()
        
        // Remove from our dictionaries
        views.removeValue(forKey: viewId)
        childViews.removeValue(forKey: viewId)
        
        result(true)
    }
    
    internal func handleUpdateView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let props = args["props"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing viewId or props", details: nil))
            return
        }
        
        print("DC MAUI: Updating view \(viewId) with props: \(props)")
        
        guard let view = views[viewId] else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found: \(viewId)", details: nil))
            return
        }
        
        // Update the view properties
        if let updatable = view as? ViewUpdatable {
            // Apply the updates
            updatable.updateProps(props: props)
            
            // Force layout update
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            // Also request layout on parent to ensure constraints are properly applied
            view.superview?.setNeedsLayout()
            view.superview?.layoutIfNeeded()
            
            // Debug log for state update
            print("DC MAUI: View \(viewId) updated successfully with new props")
            
            result(true)
        } else {
            result(FlutterError(code: "UPDATE_FAILED", message: "View does not support updates", details: nil))
        }
    }
    
    internal func handleSetChildren(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }
        
        guard let parentId = args["parentId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing parentId", details: nil))
            return
        }
        
        guard let childrenIds = args["childIds"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid childIds", details: nil))
            return
        }
        
        print("DC MAUI: Setting \(childrenIds.count) children for parent: \(parentId)")
        
        guard let parentView = views[parentId] else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "Parent view not found: \(parentId)", details: nil))
            return
        }
        
        // Remove existing children from superview
        if let existingChildren = childViews[parentId] {
            for childId in existingChildren {
                if let childView = views[childId] {
                    childView.removeFromSuperview()
                }
            }
        }
        
        // Create a vertical stack layout for children
        let parentPadding = CGFloat(parentView.tag)
        var previousView: UIView?
        
        // Add new children in specified order
        for childId in childrenIds {
            if let childView = views[childId] {
                // Add to parent
                parentView.addSubview(childView)
                
                // Set up constraints for vertical stacking
                childView.translatesAutoresizingMaskIntoConstraints = false
                
                // Leading/trailing constraints
                NSLayoutConstraint.activate([
                    childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: parentPadding),
                    childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -parentPadding)
                ])
                
                // Top constraint depends on whether this is the first child or not
                if let previousView = previousView {
                    // Position below the previous view with spacing
                    NSLayoutConstraint.activate([
                        childView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 8)
                    ])
                } else {
                    // First child, position at the top with padding
                    NSLayoutConstraint.activate([
                        childView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: parentPadding)
                    ])
                }
                
                // Last child should have a bottom constraint to the parent
                if childId == childrenIds.last {
                    NSLayoutConstraint.activate([
                        childView.bottomAnchor.constraint(lessThanOrEqualTo: parentView.bottomAnchor, constant: -parentPadding)
                    ])
                }
                
                // Update previous view for next iteration
                previousView = childView
                
                print("DC MAUI: Added child \(childId) to parent \(parentId) with constraints")
            } else {
                print("DC MAUI: WARNING - Child view \(childId) not found for parent \(parentId)")
            }
        }
        
        // Update our parent-child relationship
        childViews[parentId] = childrenIds
        
        // Force layout
        parentView.setNeedsLayout()
        parentView.layoutIfNeeded()
        
        // If this is a container, adjust its intrinsic content size
        if let containerView = parentView as? DCView {
            containerView.invalidateIntrinsicContentSize()
        }
        
        print("DC MAUI: Set children complete for \(parentId) with children: \(childrenIds)")
        
        result(true)
    }
    
    // Helper method to request layout for a view
    private func requestLayoutForView(_ view: UIView) {
        view.setNeedsLayout()
    }

    // Add a helper method to standardize event name format
    private func standardizeEventName(_ eventName: String) -> String {
        // Remove "on" prefix if it exists and lowercase the first letter
        if eventName.hasPrefix("on") && eventName.count > 2 {
            let startIndex = eventName.index(eventName.startIndex, offsetBy: 2)
            let firstChar = eventName[startIndex].lowercased()
            let restOfString = eventName[eventName.index(after: startIndex)...]
            return firstChar + restOfString
        }
        return eventName
    }

    // Modify the handleSimulateEvent method to use standardized event names
    private func handleSimulateEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventName = args["eventName"] as? String,
              let data = args["data"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        // Use standardized event name
        let standardizedEventName = standardizeEventName(eventName)
        
        // Send the event to Flutter
        sendEvent(viewId: viewId, eventName: standardizedEventName, params: data)
        result(true)
    }
    
    internal func handleGetViewInfo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing viewId", details: nil))
            return
        }
        
        guard let view = views[viewId] else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found: \(viewId)", details: nil))
            return
        }
        
        var viewInfo: [String: Any] = [
            "id": viewId
        ]
        
        // Add type information
        if let dcView = view as? DCBaseView {
            let viewType = String(describing: type(of: dcView))
            viewInfo["type"] = viewType
            
            // Add specific properties based on view type
            if let button = view as? DCButton {
                viewInfo["title"] = button.props["title"] as? String ?? ""
            } else if let text = view as? DCText {
                viewInfo["text"] = text.props["text"] as? String ?? ""
            }
            
            // Add basic properties
            if let style = dcView.props["style"] as? [String: Any] {
                viewInfo["style"] = style
            }
        }
        
        result(viewInfo)
    }
}
