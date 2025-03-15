//
//  DCActivityIndicator.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// ActivityIndicator component - displays a loading spinner
class DCActivityIndicator: DCBaseView {
    private let activityIndicator = UIActivityIndicatorView()
    
    override func setupView() {
        super.setupView()
        
        // Configure activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Set default style
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
        
        // Add to view hierarchy
        addSubview(activityIndicator)
        
        // Center the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Start animating by default
        activityIndicator.startAnimating()
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle animating state
        if let animating = props["animating"] as? Bool {
            if animating {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
        
        // Handle hiding when stopped
        if let hidesWhenStopped = props["hidesWhenStopped"] as? Bool {
            activityIndicator.hidesWhenStopped = hidesWhenStopped
        }
        
        // Handle indicator size/type
        if let type = props["type"] as? String {
            if #available(iOS 13.0, *) {
                switch type {
                case "large":
                    activityIndicator.style = .large
                case "small", "medium":
                    activityIndicator.style = .medium
                default:
                    activityIndicator.style = .medium
                }
            } else {
                // For older iOS versions
                switch type {
                case "large":
                    activityIndicator.style = .whiteLarge
                    activityIndicator.color = UIColor.gray
                case "small", "medium":
                    activityIndicator.style = .gray
                default:
                    activityIndicator.style = .gray
                }
            }
        }
        
        // Apply style properties
        if let style = props["style"] as? [String: Any] {
            // Handle color
            if let colorHex = style["color"] as? String, colorHex.hasPrefix("#") {
                activityIndicator.color = UIColor(hexString: colorHex) ?? .gray
            }
            
            // Handle custom size if provided
            if let size = style["size"] as? CGFloat {
                // Use transform to scale the activity indicator
                let scale = size / (activityIndicator.style == .whiteLarge ? 37.0 : 20.0)
                activityIndicator.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}

// Helper extension for UIColor from hex
private extension UIColor {
    convenience init?(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        var hexInt: UInt64 = 0
        
        let scanner = Scanner(string: hexString.replacingOccurrences(of: "#", with: ""))
        guard scanner.scanHexInt64(&hexInt) else { return nil }
        
        let red, green, blue, alpha: CGFloat
        
        if hexString.count == 9 {
            // 8-digit hex (with alpha)
            alpha = CGFloat((hexInt & 0xFF000000) >> 24) / 255
            red = CGFloat((hexInt & 0x00FF0000) >> 16) / 255
            green = CGFloat((hexInt & 0x0000FF00) >> 8) / 255
            blue = CGFloat(hexInt & 0x000000FF) / 255
        } else {
            // 6-digit hex (assumes full opacity)
            red = CGFloat((hexInt & 0xFF0000) >> 16) / 255
            green = CGFloat((hexInt & 0x00FF00) >> 8) / 255
            blue = CGFloat(hexInt & 0x0000FF) / 255
            alpha = 1.0
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
