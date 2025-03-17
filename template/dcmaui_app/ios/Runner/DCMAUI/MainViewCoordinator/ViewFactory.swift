//
//  ViewFactory.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Protocol for views that can be updated
protocol ViewUpdatable {
    func updateProps(props: [String: Any])
}

/// Factory for creating native views from view types and props
class ViewFactory {
    // Keep track of created views for debugging
    static var createdViewsInfo: [String: String] = [:]
    
    /// Create a view of the specified type with the given props
    static func createView(viewType: String, viewId: String, props: [String: Any]) -> UIView? {
        print("DC MAUI: Creating view of type \(viewType) with ID \(viewId)")
        
        let view: UIView?
        
        // Map viewType to actual component - Standardized to match React Native's component names
        switch viewType {
        case "View", "DCView":
            view = DCView(viewId: viewId, props: props)
            
        case "Text", "DCText":
            view = DCText(viewId: viewId, props: props)
            
        case "Image", "DCImage":
            view = DCImage(viewId: viewId, props: props)
            
        case "Button", "DCButton":
            view = DCButton(viewId: viewId, props: props)
            
        case "TextInput", "DCTextInput":
            view = DCTextInput(viewId: viewId, props: props)
            
        case "ScrollView", "DCScrollView":
            view = DCScrollView(viewId: viewId, props: props)
            
        case "Switch", "DCSwitch":
            view = DCSwitch(viewId: viewId, props: props)
            
        case "Modal", "DCModal":
            view = DCModal(viewId: viewId, props: props)
            
        case "GestureDetector", "DCGestureDetector":
            view = DCGestureDetector(viewId: viewId, props: props)
            
        case "SafeAreaView", "DCSafeAreaView":
            view = DCSafeAreaView(viewId: viewId, props: props)
            
        case "CheckBox", "DCCheckbox":
            view = DCCheckbox(viewId: viewId, props: props)
            
        case "ActivityIndicator", "DCActivityIndicator":
            view = DCActivityIndicator(viewId: viewId, props: props)
            
        case "AnimatedView", "DCAnimatedView", "Animated.View":
            view = DCAnimatedView(viewId: viewId, props: props)
            
        case "TouchableOpacity", "DCTouchableOpacity":
            view = DCTouchableOpacity(viewId: viewId, props: props)
            
        case "TouchableHighlight", "DCTouchableHighlight":
            view = DCTouchableHighlight(viewId: viewId, props: props)
            
        case "TouchableWithoutFeedback", "DCTouchableWithoutFeedback":
            view = DCTouchableWithoutFeedback(viewId: viewId, props: props)
            
        case "ListView", "DCListView", "FlatList":
            view = DCListView(viewId: viewId, props: props)
            
        default:
            // Default to base view for unknown types for graceful fallback
            print("DC MAUI: WARNING - Unknown view type: \(viewType), using default DCView")
            view = DCView(viewId: viewId, props: props)
        }
        
        // Track created views
        if let view = view {
            createdViewsInfo[viewId] = viewType
            
            // Root view handling
            if viewId == "view_0" {
                setupRootView(view)
            }
        }
        
        return view
    }
    
    // Separate method for cleaner root view setup (React Native style)
    private static func setupRootView(_ rootView: UIView) {
        // Find the root view controller
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        // Add view to hierarchy
        rootVC.view.addSubview(rootView)
        
        // Configure constraints
        rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor),
            rootView.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor)
        ])
    }
    
    // Add a debug method to print all created views
    static func debugPrintCreatedViews() {
        print("DC MAUI DEBUG: ---- CREATED VIEWS ----")
        for (viewId, viewType) in createdViewsInfo {
            print("DC MAUI DEBUG: View ID: \(viewId), Type: \(viewType)")
        }
        print("DC MAUI DEBUG: ---- END CREATED VIEWS ----")
    }
}
