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
    /// Create a view of the specified type with the given props
    static func createView(viewType: String, viewId: String, props: [String: Any]) -> UIView? {
        print("DC MAUI: Creating view of type \(viewType) with ID \(viewId)")
        
        let view: UIView?
        
        switch viewType {
        case "DCView", "View":  // Accept both to maintain backward compatibility
            view = DCView(viewId: viewId, props: props)
            
        case "DCText", "Text":
            view = DCText(viewId: viewId, props: props)
            
        case "DCImage", "Image":
            view = DCImage(viewId: viewId, props: props)
            
        case "DCButton", "Button":
            view = DCButton(viewId: viewId, props: props)
            
        case "DCSwitch", "Switch":
            view = DCSwitch(viewId: viewId, props: props)
            
        case "DCCheckbox", "Checkbox":
            view = DCCheckbox(viewId: viewId, props: props)
            
        case "DCListView", "ListView":
            view = DCListView(viewId: viewId, props: props)
            
        case "DCGestureDetector", "GestureDetector":
            view = DCGestureDetector(viewId: viewId, props: props)
            
        case "DCModal", "Modal":
            view = DCModal(viewId: viewId, props: props)
            
        case "DCAnimatedView", "AnimatedView":
            view = DCAnimatedView(viewId: viewId, props: props)
            
        default:
            print("DC MAUI: Unknown view type: \(viewType)")
            return nil
        }
        
        // Set a default frame if none exists
        if let uiView = view as? UIView, uiView.frame.isEmpty {
            uiView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        
        // Add the view to the view hierarchy if it's the root container
        if viewId == "view_0", let rootContainer = view {
            // Find key window using newer API for iOS 13+
            if #available(iOS 13.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    if let rootVC = window.rootViewController {
                        // First, check if view is already added (avoid duplicates)
                        if rootContainer.superview == nil {
                            rootVC.view.addSubview(rootContainer)
                            
                            // Make it fill the entire view for the root container
                            rootContainer.translatesAutoresizingMaskIntoConstraints = false
                            
                            NSLayoutConstraint.activate([
                                rootContainer.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor),
                                rootContainer.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor),
                                rootContainer.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
                                rootContainer.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor)
                            ])
                            
                            // Apply a visible background color for debugging
                            rootContainer.backgroundColor = UIColor.white
                            
                            print("DC MAUI: Root container added to view hierarchy with constraints")
                            
                            // Force layout
                            rootVC.view.setNeedsLayout()
                            rootVC.view.layoutIfNeeded()
                        }
                    }
                }
            } else {
                // Fallback for older iOS versions
                if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                   let rootVC = keyWindow.rootViewController {
                    if rootContainer.superview == nil {
                        rootVC.view.addSubview(rootContainer)
                        
                        rootContainer.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            rootContainer.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor),
                            rootContainer.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor),
                            rootContainer.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
                            rootContainer.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor)
                        ])
                        
                        // Apply a visible background color for debugging
                        rootContainer.backgroundColor = UIColor.white
                        
                        print("DC MAUI: Root container added to view hierarchy with constraints")
                        
                        // Force layout
                        rootVC.view.setNeedsLayout()
                        rootVC.view.layoutIfNeeded()
                    }
                }
            }
        }
        
        // For debugging, add a visible boundary to all views
        if let uiView = view {
            // Uncomment this to see view boundaries during development
            uiView.layer.borderWidth = 0.5
            uiView.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        return view
    }
}
