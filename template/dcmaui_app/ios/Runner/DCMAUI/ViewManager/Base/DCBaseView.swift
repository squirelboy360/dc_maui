//
//  DCBaseView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Base class for all DC MAUI native views
class DCBaseView: UIView, ViewUpdatable {
    let viewId: String
    var props: [String: Any]
    private var eventListeners: [String: Bool] = [:]
    
    init(viewId: String, props: [String: Any]) {
        self.viewId = viewId
        self.props = props
        super.init(frame: .zero)
        setupView()
        updateProps(props: props)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        // Base setup for view
    }
    
    func updateProps(props: [String: Any]) {
        self.props = props
        
        // Handle common style properties
        if let style = props["style"] as? [String: Any] {
            applyStyleProperties(style)
        }
    }
    
    // Simplified styling that works with Auto Layout
    func applyStyleProperties(_ style: [String: Any]) {
        // Background Color
        if let backgroundColorStr = style["backgroundColor"] as? String, backgroundColorStr.hasPrefix("#") {
            backgroundColor = UIColor(hexString: backgroundColorStr)
        }
        
        // Border radius
        if let borderRadius = style["borderRadius"] as? CGFloat {
            layer.cornerRadius = borderRadius
            layer.masksToBounds = true
        }
        
        // Border
        if let borderWidth = style["borderWidth"] as? CGFloat {
            layer.borderWidth = borderWidth
        }
        
        if let borderColor = style["borderColor"] as? String, borderColor.hasPrefix("#") {
            layer.borderColor = UIColor(hexString: borderColor).cgColor
        }
        
        // Width and Height
        if let width = style["width"] as? CGFloat, width > 0 && !width.isInfinite {
            // Remove any existing width constraints
            for constraint in constraints where constraint.firstAttribute == .width {
                removeConstraint(constraint)
            }
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = style["height"] as? CGFloat, height > 0 && !height.isInfinite {
            // Remove any existing height constraints
            for constraint in constraints where constraint.firstAttribute == .height {
                removeConstraint(constraint)
            }
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        // Handle padding - storing in tag for use in layout
        if let padding = style["padding"] as? CGFloat {
            tag = Int(padding)
        }
        
        // Margins are handled through Auto Layout constraints in handleSetChildren
    }
    
    // Associated objects keys for style properties
    private struct AssociatedKeys {
        static var paddingKey = "padding"
        static var marginTopKey = "marginTop"
        static var marginBottomKey = "marginBottom"
        static var marginLeftKey = "marginLeft" 
        static var marginRightKey = "marginRight"
        static var positionKey = "position"
        static var topKey = "top"
        static var leftKey = "left"
        static var bottomKey = "bottom"
        static var rightKey = "right"
        static var flexDirectionKey = "flexDirection"
        static var justifyContentKey = "justifyContent"
        static var alignItemsKey = "alignItems"
        static var flexWrapKey = "flexWrap"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Apply frame-based layout to children if needed
        for (index, subview) in subviews.enumerated() {
            // Simple vertical stacking if no specific layout is defined
            if subview.constraints.isEmpty && subview.frame.size == .zero {
                let padding = CGFloat(tag)
                let yPos = index > 0 ? subviews[index-1].frame.maxY + padding : padding
                subview.frame = CGRect(
                    x: padding,
                    y: yPos,
                    width: bounds.width - (padding * 2),
                    height: subview.sizeThatFits(CGSize(width: bounds.width - (padding * 2), height: .greatestFiniteMagnitude)).height
                )
            }
        }
        
        // Debugging
        if frame.isEmpty {
            print("DC MAUI: Warning - View \(viewId) has zero frame after layout")
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if subviews.isEmpty {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        // Calculate height based on last subview
        if let lastSubview = subviews.last {
            let padding = CGFloat(tag)
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: lastSubview.frame.maxY + padding
            )
        }
        
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    // Add listener for an event type
    func addEventListener(_ eventType: String) {
        eventListeners[eventType] = true
    }
    
    // Remove listener for an event type
    func removeEventListener(_ eventType: String) {
        eventListeners[eventType] = nil
    }
    
    // Check if we're listening for a specific event
    func hasEventListener(_ eventType: String) -> Bool {
        return eventListeners[eventType] == true
    }
    
    // Helper method to get layout position values
    func getLayoutLeft() -> CGFloat {
        return frame.origin.x
    }
    
    func getLayoutTop() -> CGFloat {
        return frame.origin.y
    }
}

// Extension for UIColor to support hex string conversion
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
