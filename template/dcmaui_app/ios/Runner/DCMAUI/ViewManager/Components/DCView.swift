//
//  DCView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Basic view component matching React Native's View
class DCView: DCBaseView {
    
    override func setupView() {
        super.setupView()
        // The basic view doesn't need any special setup beyond the base view
        // It will use the layout algorithm in DCBaseView
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle accessibility properties
        if let accessible = props["accessible"] as? Bool {
            isAccessibilityElement = accessible
        }
        
        if let pointerEvents = props["pointerEvents"] as? String {
            switch pointerEvents {
            case "none":
                isUserInteractionEnabled = false
                alpha = 0.5  // Visual indication that it's disabled
                
            case "box-only":
                isUserInteractionEnabled = true
                for subview in subviews {
                    subview.isUserInteractionEnabled = false
                }
                
            case "box-none":
                isUserInteractionEnabled = false
                for subview in subviews {
                    subview.isUserInteractionEnabled = true
                }
                
            case "auto":
                isUserInteractionEnabled = true
                for subview in subviews {
                    subview.isUserInteractionEnabled = true
                }
                
            default:
                break
            }
        }
        
        // Additional view-specific style properties
        if let style = props["style"] as? [String: Any] {
            // Handle shadow properties
            if let shadowColor = style["shadowColor"] as? String, 
               let shadowOpacity = style["shadowOpacity"] as? Float,
               let shadowRadius = style["shadowRadius"] as? CGFloat {
                
                layer.shadowColor = UIColor(hexString: shadowColor).cgColor
                layer.shadowOpacity = shadowOpacity
                layer.shadowRadius = shadowRadius
                
                // Handle shadow offset
                var shadowOffset = CGSize.zero
                if let shadowOffsetWidth = style["shadowOffsetWidth"] as? CGFloat {
                    shadowOffset.width = shadowOffsetWidth
                }
                if let shadowOffsetHeight = style["shadowOffsetHeight"] as? CGFloat {
                    shadowOffset.height = shadowOffsetHeight
                }
                layer.shadowOffset = shadowOffset
            }
        }
        
        setNeedsLayout()
    }
    
    // Fix: Add override keyword and match the access modifier from DCBaseView
    override func getPadding() -> CGFloat {
        return max(padding.left, max(padding.right, max(padding.top, padding.bottom)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Debug output for frame
        print("DC MAUI: \(viewId) layoutSubviews with frame: \(frame), bounds: \(bounds), subviews: \(subviews.count)")
        
        // Ensure non-empty size
        if bounds.width <= 0 || bounds.height <= 0 {
            print("DC MAUI: WARNING - Empty bounds in \(viewId), fixing...")
            bounds.size = CGSize(width: max(bounds.width, 100), height: max(bounds.height, 100))
        }
        
        // Apply layout to all children
        let padValue = getPadding()
        var yPos = padding.top
        
        for (index, subview) in subviews.enumerated() {
            // Skip layout for absolute positioned views (handled by DCBaseView)
            if let dcView = subview as? DCBaseView, dcView.position == "absolute" {
                continue
            }
            
            let availableWidth = bounds.width - (padding.left + padding.right)
            let subviewTypeName = type(of: subview)
            
            // Handle special cases
            var calculatedHeight: CGFloat = 0
            
            if let buttonView = subview as? DCButton {
                calculatedHeight = 44.0
            } else if let textView = subview as? DCText {
                let textSize = textView.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
                calculatedHeight = max(textSize.height, 24.0)
            } else if subview.intrinsicContentSize.height != UIView.noIntrinsicMetric {
                calculatedHeight = subview.intrinsicContentSize.height
            } else {
                calculatedHeight = subview.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude)).height
                if calculatedHeight <= 0 {
                    calculatedHeight = 44.0 // Default height
                }
            }
            
            // Ensure minimum height
            calculatedHeight = max(calculatedHeight, 30.0)
            
            // Set frame with padding applied
            let newFrame = CGRect(
                x: padding.left,
                y: yPos,
                width: availableWidth,
                height: calculatedHeight
            )
            
            // Apply frame & force layout
            subview.frame = newFrame
            subview.setNeedsLayout()
            subview.layoutIfNeeded()
            
            // Update yPos for the next subview with spacing
            yPos = subview.frame.maxY + 10 // 10pt spacing between views
        }
        
        // Special handling for root view
        if viewId == "view_0" && superview != nil && (bounds.width < 1 || bounds.height < 1) {
            frame = superview!.bounds
        }
        
        // Debug output for final frame
        print("DC MAUI: \(viewId) final frame after layout: \(frame)")
    }

    // Override adding subviews to ensure proper layout updating
    override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        setNeedsLayout()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Don't let superview override our explicitly set dimensions
        if superview != nil {
            // Only grab superview bounds if we don't have our own size
            if frame.width <= 1 || frame.height <= 1 {
                let superviewBounds = superview!.bounds
                frame = CGRect(x: 0, y: 0, width: superviewBounds.width, height: superviewBounds.height)
                print("DC MAUI: \(viewId) using superview bounds: \(superviewBounds)")
            } else {
                print("DC MAUI: \(viewId) keeping existing frame: \(frame)")
            }
        }
        
        // If this is the root view and it just got added to the view hierarchy
        if viewId == "view_0" && superview != nil {
            print("DC MAUI: Root view added to superview with frame: \(frame)")
            
            // Ensure the root view fills its superview
            if frame.size.width < 1 || frame.size.height < 1 {
                frame = superview!.bounds
            }
            
            // Force background color for debugging
            if backgroundColor == nil {
                backgroundColor = .white  // Ensure visibility
            }
            
            setNeedsLayout()
        }
    }
    
    // Calculate proper intrinsic content size based on children and padding
    override var intrinsicContentSize: CGSize {
        if subviews.isEmpty {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        let padValue = getPadding()
        var maxY: CGFloat = 0
        
        for subview in subviews {
            let subviewMaxY = subview.frame.maxY
            if subviewMaxY > maxY {
                maxY = subviewMaxY
            }
        }
        
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: maxY + padding.bottom
        )
    }
}
