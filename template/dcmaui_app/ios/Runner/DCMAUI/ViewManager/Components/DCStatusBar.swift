//
//  DCStatusBar.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Status Bar component that matches React Native's StatusBar for controlling status bar appearance
class DCStatusBar: NSObject {
    // Static storage for current settings
    private static var currentSettings: [String: Any] = [
        "barStyle": "default",
        "hidden": false,
        "translucent": false,
        "backgroundColor": "#000000",
        "networkActivityIndicatorVisible": false
    ]
    
    // Static method to update status bar settings
    static func updateProps(_ props: [String: Any]) {
        // Process props to update global settings
        for (key, value) in props {
            currentSettings[key] = value
        }
        
        // Apply changes immediately
        applySettings()
    }
    
    static func applySettings() {
        // Get key properties
        let barStyle = currentSettings["barStyle"] as? String ?? "default"
        let hidden = currentSettings["hidden"] as? Bool ?? false
        
        // Apply settings
        DispatchQueue.main.async {
            // Handle bar style (light or dark content)
            if #available(iOS 13.0, *) {
                let style: UIStatusBarStyle = (barStyle == "light-content") ? .lightContent : 
                                             (barStyle == "dark-content") ? .darkContent : .default
                
                // We need to find all view controllers and update their status bar style
                applyStatusBarStyle(style)
            } else {
                // Fallback for older iOS versions
                let style: UIStatusBarStyle = (barStyle == "light-content") ? .lightContent : .default
                UIApplication.shared.statusBarStyle = style
            }
            
            // Handle hidden state
            UIApplication.shared.isStatusBarHidden = hidden
            
            // Handle network activity indicator
            let showNetworkIndicator = currentSettings["networkActivityIndicatorVisible"] as? Bool ?? false
            UIApplication.shared.isNetworkActivityIndicatorVisible = showNetworkIndicator
        }
    }
    
    static private func applyStatusBarStyle(_ style: UIStatusBarStyle) {
        if #available(iOS 13.0, *) {
            // Get the key window's topmost view controller
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            
            if let window = windowScene?.windows.first(where: { $0.isKeyWindow }) {
                // Find the topmost view controller
                var topController = window.rootViewController
                while let presentedController = topController?.presentedViewController {
                    topController = presentedController
                }
                
                // Set the style by forcing view controller to refresh status bar
                if let controller = topController as? StatusBarStyleController {
                    controller.statusBarStyle = style
                    controller.setNeedsStatusBarAppearanceUpdate()
                } else {
                    // If the controller doesn't conform to our protocol, we can try to swizzle or use other techniques
                    // For simplicity, we'll just attempt to create a global override
                    let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
                    keyWindow?.windowScene?.statusBarManager?.statusBarStyle = style
                }
            }
        }
    }
    
    // For background color we need a view overlay
    static func setStatusBarBackgroundColor(color: UIColor) {
        if #available(iOS 13.0, *) {
            let statusBarHeight: CGFloat = statusBarHeight()
            
            let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight))
            statusBarView.backgroundColor = color
            statusBarView.tag = 38482 // Unique tag to find/remove it later
            
            // Remove any existing status bar view
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.viewWithTag(38482)?.removeFromSuperview()
                keyWindow.addSubview(statusBarView)
            }
        }
    }
    
    static func statusBarHeight() -> CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
}

// Protocol to allow updating status bar style
protocol StatusBarStyleController {
    var statusBarStyle: UIStatusBarStyle { get set }
}
