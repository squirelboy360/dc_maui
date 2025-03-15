//
//  LayoutHelper.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Helper class to manage layout properties similar to Flexbox but using native UIKit constraints
class LayoutHelper {
    /// Apply Flexbox-like constraints to a view
    static func applyFlexboxLayout(to view: UIView, style: [String: Any]) {
        // Handle flex direction
        if let flexDirection = style["flexDirection"] as? String {
            applyFlexDirection(flexDirection, to: view)
        }
        
        // Handle justify content
        if let justifyContent = style["justifyContent"] as? String {
            applyJustifyContent(justifyContent, to: view)
        }
        
        // Handle align items
        if let alignItems = style["alignItems"] as? String {
            applyAlignItems(alignItems, to: view)
        }
        
        // Handle flex grow
        if let flexGrow = style["flexGrow"] as? CGFloat {
            applyFlexGrow(flexGrow, to: view)
        }
    }
    
    private static func applyFlexDirection(_ direction: String, to view: UIView) {
        // Set stack view arrangement direction if view is a container with children
        if let stackView = view as? UIStackView {
            switch direction {
                case "row": 
                    stackView.axis = .horizontal
                case "row-reverse": 
                    stackView.axis = .horizontal
                    stackView.semanticContentAttribute = .forceRightToLeft
                case "column": 
                    stackView.axis = .vertical
                case "column-reverse": 
                    stackView.axis = .vertical
                    stackView.semanticContentAttribute = .forceRightToLeft
                default:
                    stackView.axis = .vertical
            }
        }
    }
    
    private static func applyJustifyContent(_ justifyContent: String, to view: UIView) {
        if let stackView = view as? UIStackView {
            switch justifyContent {
                case "flex-start": 
                    stackView.distribution = .fill
                    stackView.alignment = .leading
                case "flex-end": 
                    stackView.distribution = .fill
                    stackView.alignment = .trailing
                case "center": 
                    stackView.distribution = .fill
                    stackView.alignment = .center
                case "space-between": 
                    stackView.distribution = .equalSpacing
                case "space-around": 
                    stackView.distribution = .equalCentering
                case "space-evenly":
                    // UIStackView doesn't have a direct equivalent for space-evenly
                    // We would need a custom implementation 
                    stackView.distribution = .equalSpacing
                default:
                    stackView.distribution = .fill
            }
        }
    }
    
    private static func applyAlignItems(_ alignItems: String, to view: UIView) {
        if let stackView = view as? UIStackView {
            switch alignItems {
                case "flex-start":
                    stackView.alignment = .leading
                case "flex-end":
                    stackView.alignment = .trailing
                case "center":
                    stackView.alignment = .center
                case "baseline":
                    stackView.alignment = .firstBaseline
                case "stretch":
                    stackView.alignment = .fill
                default:
                    stackView.alignment = .fill
            }
        }
    }
    
    private static func applyFlexGrow(_ flexGrow: CGFloat, to view: UIView) {
        // For UIStackView children, we can use content hugging and compression resistance
        if flexGrow > 0 {
            view.setContentHuggingPriority(UILayoutPriority(rawValue: 250 - Float(flexGrow) * 10), for: .horizontal)
            view.setContentHuggingPriority(UILayoutPriority(rawValue: 250 - Float(flexGrow) * 10), for: .vertical)
        }
    }
}
