//
//  DCBaseView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Base class for all DC MAUI views
class DCBaseView: UIView, ViewUpdatable {
    var viewId: String?
    
    init(viewId: String, props: [String: Any]) {
        self.viewId = viewId
        super.init(frame: .zero)
        
        setupView()
        updateProps(props: props)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /// Set up the view's initial configuration
    func setupView() {
        // Default background color is clear 
        backgroundColor = .clear
    }
    
    /// Update the view with new props
    func updateProps(props: [String: Any]) {
        // Handle common style properties
        if let style = props["style"] as? [String: Any] {
            // Background color
            if let bgColorHex = style["backgroundColor"] as? String, bgColorHex.hasPrefix("#"),
               let bgColor = UIColor(hexString: bgColorHex) {
                backgroundColor = bgColor
            }
            
            // Margin handling
            applyMargin(style: style)
            
            // Border properties
            if let borderRadius = style["borderRadius"] as? CGFloat {
                layer.cornerRadius = borderRadius
                clipsToBounds = true
            }
            
            if let borderWidth = style["borderWidth"] as? CGFloat {
                layer.borderWidth = borderWidth
            }
            
            if let borderColorHex = style["borderColor"] as? String, borderColorHex.hasPrefix("#"),
               let borderColor = UIColor(hexString: borderColorHex) {
                layer.borderColor = borderColor.cgColor
            }
            
            // Opacity
            if let opacity = style["opacity"] as? CGFloat {
                alpha = opacity
            }
        }
    }
    
    /// Apply margin to the view - this needs to be handled by the parent view
    /// Here we just store the values for reference
    private func applyMargin(style: [String: Any]) {
        // Margin is actually applied by the parent view, but we can store it
        // for reference in case subclasses need it
        var margin = UIEdgeInsets.zero
        
        if let marginValue = style["margin"] as? CGFloat {
            margin = UIEdgeInsets(top: marginValue, left: marginValue, bottom: marginValue, right: marginValue)
        } else {
            if let marginTop = style["marginTop"] as? CGFloat {
                margin.top = marginTop
            }
            if let marginBottom = style["marginBottom"] as? CGFloat {
                margin.bottom = marginBottom
            }
            if let marginLeft = style["marginLeft"] as? CGFloat {
                margin.left = marginLeft
            }
            if let marginRight = style["marginRight"] as? CGFloat {
                margin.right = marginRight
            }
        }
        
        // Store these values in the layer's name as a hack (just for debugging)
        // In a real implementation, you would use these values when adding this view as a subview
        layer.name = "margin:\(margin.top),\(margin.left),\(margin.bottom),\(margin.right)"
    }
}
