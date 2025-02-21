import UIKit
import YogaKit

// Add these extensions right after imports
private extension CGFloat {
    var toYGFloat: Float {
        return Float(self)
    }
}

private extension Float {
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
}

// YGValue helpers
extension YGValue {
    static let undefined = YGValue(value: Float.nan, unit: .undefined)
    static let auto = YGValue(value: Float.nan, unit: .auto)
    
    static func point(_ value: Float) -> YGValue {
        YGValue(value: value, unit: .point)
    }
    
    static func percent(_ value: Float) -> YGValue {
        YGValue(value: value, unit: .percent)
    }
}

enum LayoutType: String {
    case flex
    case absolute
    case relative
}

// Step 1: Keep the property as CGFloat
struct LayoutConfig {
    var width: YGValue = YGValue(value: Float.nan, unit: .auto)
    var height: YGValue = YGValue(value: Float.nan, unit: .auto)
    var minWidth: YGValue?
    var minHeight: YGValue?
    var maxWidth: YGValue?
    var maxHeight: YGValue?
    var flex: Float?
    var flexGrow: Float?
    var flexShrink: Float?
    var flexBasis: YGValue?
    var flexDirection: YGFlexDirection = .column
    var justifyContent: YGJustify = .flexStart
    var alignItems: YGAlign = .stretch
    var alignSelf: YGAlign = .auto
    var position: YGPositionType = .relative
    var margin = UIEdgeInsets.zero
    var padding = UIEdgeInsets.zero
    var left: YGValue?
    var top: YGValue?
    var right: YGValue?
    var bottom: YGValue?
    var display: YGDisplay?
    var border: [String: CGFloat]?  // Changed from Float to CGFloat since border properties expect CGFloat

    // Step 2: Update the initialization
    init(from dict: [String: Any]) {
        print("Initializing LayoutConfig with: \(dict)")
        
        // Handle width
        if let widthDict = dict["width"] as? [String: Any] {
            let value = Float(truncating: widthDict["value"] as? NSNumber ?? 0)
            let unitString = widthDict["unit"] as? String ?? "point"
            
            switch unitString {
            case "percent":
                width = YGValue(value: value, unit: .percent)
                print("Setting percent width: \(value)%")
            case "point":
                width = YGValue(value: value, unit: .point)
                print("Setting point width: \(value)pt")
            case "auto":
                width = YGValue(value: Float.nan, unit: .auto)
                print("Setting auto width")
            default:
                width = YGValue(value: Float.nan, unit: .undefined)
                print("Setting undefined width")
            }
        }
        
        // Handle height
        if let heightDict = dict["height"] as? [String: Any] {
            let value = Float(truncating: heightDict["value"] as? NSNumber ?? 0)
            let unitString = heightDict["unit"] as? String ?? "point"
            
            switch unitString {
            case "percent":
                height = YGValue(value: value, unit: .percent)
                print("Setting percent height: \(value)%")
            case "point":
                height = YGValue(value: value, unit: .point)
                print("Setting point height: \(value)pt")
            case "auto":
                height = YGValue(value: Float.nan, unit: .auto)
                print("Setting auto height")
            default:
                height = YGValue(value: Float.nan, unit: .undefined)
                print("Setting undefined height")
            }
        }
        
        // Add explicit debug logging
        print("Parsed width: \(width)")
        print("Parsed height: \(height)")
        
        // Position type
        if let positionStr = dict["position"] as? String {
            position = positionStr == "absolute" ? .absolute : .relative
        }
        
        // Position values
        if let leftValue = dict["left"] as? Double {
            left = YGValue(value: Float(leftValue), unit: .point)
        }
        if let topValue = dict["top"] as? Double {
            top = YGValue(value: Float(topValue), unit: .point)
        }
        if let rightValue = dict["right"] as? Double {
            right = YGValue(value: Float(rightValue), unit: .point)
        }
        if let bottomValue = dict["bottom"] as? Double {
            bottom = YGValue(value: Float(bottomValue), unit: .point)
        }
        
        // Flex properties
        if let flexValue = dict["flex"] as? Double {
            flex = Float(flexValue)
        }
        if let growValue = dict["flexGrow"] as? Double {
            flexGrow = Float(growValue)
        }
        if let shrinkValue = dict["flexShrink"] as? Double {
            flexShrink = Float(shrinkValue)
        }
        
        // Direction and alignment
        if let direction = dict["flexDirection"] as? String {
            switch direction {
            case "row": flexDirection = .row
            case "rowReverse": flexDirection = .rowReverse
            case "columnReverse": flexDirection = .columnReverse
            default: flexDirection = .column
            }
        }
        
        if let justify = dict["justifyContent"] as? String {
            switch justify {
            case "center": justifyContent = .center
            case "flexEnd": justifyContent = .flexEnd
            case "spaceBetween": justifyContent = .spaceBetween
            case "spaceAround": justifyContent = .spaceAround
            case "spaceEvenly": justifyContent = .spaceEvenly
            default: justifyContent = .flexStart
            }
        }
        
        if let align = dict["alignItems"] as? String {
            switch align {
            case "center": alignItems = .center
            case "flexEnd": alignItems = .flexEnd
            case "baseline": alignItems = .baseline
            case "stretch": alignItems = .stretch
            default: alignItems = .flexStart
            }
        }
        
        // Parse margins and padding
        if let margins = dict["margin"] as? [String: Double] {
            margin = UIEdgeInsets(
                top: CGFloat(margins["top"] ?? 0),
                left: CGFloat(margins["left"] ?? 0),
                bottom: CGFloat(margins["bottom"] ?? 0),
                right: CGFloat(margins["right"] ?? 0)
            )
        }
        
        if let paddings = dict["padding"] as? [String: Double] {
            padding = UIEdgeInsets(
                top: CGFloat(paddings["top"] ?? 0),
                left: CGFloat(paddings["left"] ?? 0),
                bottom: CGFloat(paddings["bottom"] ?? 0),
                right: CGFloat(paddings["right"] ?? 0)
            )
        }

        // Add parsing for missing properties
        if let minWidthDict = dict["minWidth"] as? [String: Any] {
            minWidth = parseYGValue(from: minWidthDict)
        }
        if let minHeightDict = dict["minHeight"] as? [String: Any] {
            minHeight = parseYGValue(from: minHeightDict)
        }
        if let maxWidthDict = dict["maxWidth"] as? [String: Any] {
            maxWidth = parseYGValue(from: maxWidthDict)
        }
        if let maxHeightDict = dict["maxHeight"] as? [String: Any] {
            maxHeight = parseYGValue(from: maxHeightDict)
        }
        if let displayStr = dict["display"] as? String {
            display = displayStr == "none" ? .none : .flex
        }
        if let alignSelfStr = dict["alignSelf"] as? String {
            if let parsedAlign = parseYGAlign(from: alignSelfStr) {
                alignSelf = parsedAlign
            }
        }
        if let flexGrowValue = dict["flexGrow"] as? Double {
            flexGrow = Float(flexGrowValue)
        }
        if let flexShrinkValue = dict["flexShrink"] as? Double {
            flexShrink = Float(flexShrinkValue)
        }
        if let flexBasisDict = dict["flexBasis"] as? [String: Any] {
            flexBasis = parseYGValue(from: flexBasisDict)
        }
        // Convert border values directly to CGFloat
        if let borderDict = dict["border"] as? [String: Double] {
            border = borderDict.mapValues { CGFloat($0) }  // Convert to CGFloat during initialization
        }
    }
    
    // Helper function to parse YGValue from dictionary
    private func parseYGValue(from dict: [String: Any]) -> YGValue {
        let value = Float(truncating: dict["value"] as? NSNumber ?? 0)
        let unitString = dict["unit"] as? String ?? "point"
        
        switch unitString {
        case "percent": return YGValue(value: value, unit: .percent)
        case "point": return YGValue(value: value, unit: .point)
        case "auto": return YGValue(value: Float.nan, unit: .auto)
        default: return YGValue(value: Float.nan, unit: .undefined)
        }
    }
    
    private func parseYGAlign(from string: String) -> YGAlign? {
        switch string {
        case "auto": return .auto
        case "flexStart": return .flexStart
        case "center": return .center
        case "flexEnd": return .flexEnd
        case "stretch": return .stretch
        case "baseline": return .baseline
        case "spaceBetween": return .spaceBetween
        case "spaceAround": return .spaceAround
        default: return nil
        }
    }

    // Add this method to LayoutConfig struct
    func toJson() -> [String: Any] {
        var json: [String: Any] = [:]
        
        // Width
        if width.unit != .undefined {
            json["width"] = ["value": width.value, "unit": width.unit == .percent ? "percent" : "point"]
        }
        
        // Height
        if height.unit != .undefined {
            json["height"] = ["value": height.value, "unit": height.unit == .percent ? "percent" : "point"]
        }
        
        // Minimum dimensions
        if let minWidth = minWidth {
            json["minWidth"] = ["value": minWidth.value, "unit": minWidth.unit == .percent ? "percent" : "point"]
        }
        if let minHeight = minHeight {
            json["minHeight"] = ["value": minHeight.value, "unit": minHeight.unit == .percent ? "percent" : "point"]
        }
        
        // Maximum dimensions
        if let maxWidth = maxWidth {
            json["maxWidth"] = ["value": maxWidth.value, "unit": maxWidth.unit == .percent ? "percent" : "point"]
        }
        if let maxHeight = maxHeight {
            json["maxHeight"] = ["value": maxHeight.value, "unit": maxHeight.unit == .percent ? "percent" : "point"]
        }
        
        // Flex properties
        if let flex = flex { json["flex"] = flex }
        if let flexGrow = flexGrow { json["flexGrow"] = flexGrow }
        if let flexShrink = flexShrink { json["flexShrink"] = flexShrink }
        if let flexBasis = flexBasis {
            json["flexBasis"] = ["value": flexBasis.value, "unit": flexBasis.unit == .percent ? "percent" : "point"]
        }
        
        // Layout properties
        json["flexDirection"] = flexDirection == .row ? "row" : "column"
        json["justifyContent"] = justifyContent == .center ? "center" : "flexStart"
        json["alignItems"] = alignItems == .center ? "center" : "stretch"
        json["position"] = position == .absolute ? "absolute" : "relative"
        
        // Spacing
        if margin != .zero {
            json["margin"] = [
                "top": margin.top,
                "left": margin.left,
                "bottom": margin.bottom,
                "right": margin.right
            ]
        }
        
        if padding != .zero {
            json["padding"] = [
                "top": padding.top,
                "left": padding.left,
                "bottom": padding.bottom,
                "right": padding.right
            ]
        }
        
        // Border
        if let border = border {
            json["border"] = border
        }
        
        return json
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    private struct YGNodeKey {
        static var node = "YGNode"
    }
    
    // Remove duplicate yogaNodes property since it's already defined in NativeUIManager
    
    // Node management
    private func getYogaNode(for view: UIView) -> YGNodeRef? {
        if let existingNode = objc_getAssociatedObject(view, &YGNodeKey.node) as? YGNodeRef {
            return existingNode
        }
        
        let node = YGNodeNew()
        objc_setAssociatedObject(view, &YGNodeKey.node, node, .OBJC_ASSOCIATION_RETAIN)
        yogaNodes[view.hash.description] = node
        return node
    }
    
    internal func applyYogaLayout(to view: UIView, config: LayoutConfig) {
        view.yoga.isEnabled = true
        
        // Important: Set initial frame to parent bounds or screen size
        let screenSize = UIScreen.main.bounds.size
        let parentSize = view.superview?.bounds.size ?? screenSize
        view.frame = CGRect(origin: .zero, size: parentSize)
        
        view.configureLayout { layout in
            // Handle percentage dimensions
            if config.width.unit == .percent {
                let percentValue = config.width.value
                let actualWidth = parentSize.width * (CGFloat(percentValue) / 100.0)
                layout.width = YGValue(value: Float(actualWidth), unit: .point)
                print("Setting width: \(actualWidth)pt from \(percentValue)%")
            } else {
                layout.width = config.width
            }
            
            if config.height.unit == .percent {
                let percentValue = config.height.value
                let actualHeight = parentSize.height * (CGFloat(percentValue) / 100.0)
                layout.height = YGValue(value: Float(actualHeight), unit: .point)
                print("Setting height: \(actualHeight)pt from \(percentValue)%")
            } else {
                layout.height = config.height
            }
            
            // Handle absolute positioning
            if config.position == .absolute {
                layout.position = .absolute
                
                // Convert position values to points if needed
                if let left = config.left {
                    layout.left = (left.unit == .percent) ? 
                        YGValue(value: Float(parentSize.width * CGFloat(left.value) / 100.0), unit: .point) : left
                }
                if let right = config.right {
                    layout.right = (right.unit == .percent) ?
                        YGValue(value: Float(parentSize.width * CGFloat(right.value) / 100.0), unit: .point) : right
                }
                if let top = config.top {
                    layout.top = (top.unit == .percent) ?
                        YGValue(value: Float(parentSize.height * CGFloat(top.value) / 100.0), unit: .point) : top
                }
                if let bottom = config.bottom {
                    layout.bottom = (bottom.unit == .percent) ?
                        YGValue(value: Float(parentSize.height * CGFloat(bottom.value) / 100.0), unit: .point) : bottom
                }
            }
            
            // 1. Dimensions
            if let minWidth = config.minWidth { layout.minWidth = minWidth }
            if let minHeight = config.minHeight { layout.minHeight = minHeight }
            if let maxWidth = config.maxWidth { layout.maxWidth = maxWidth }
            if let maxHeight = config.maxHeight { layout.maxHeight = maxHeight }
            
            // 2. Position & Display
            layout.position = config.position
            if let display = config.display { layout.display = display }
            
            // 3. Flex Properties
            layout.flexDirection = config.flexDirection
            layout.justifyContent = config.justifyContent
            layout.alignItems = config.alignItems
            layout.alignSelf = config.alignSelf
            if let flex = config.flex { layout.flex = CGFloat(flex) }
            if let flexGrow = config.flexGrow { layout.flexGrow = CGFloat(flexGrow) }
            if let flexShrink = config.flexShrink { layout.flexShrink = CGFloat(flexShrink) }
            if let flexBasis = config.flexBasis { layout.flexBasis = flexBasis }
            
            // 4. Spacing (Margin, Padding, Border)
            // Margins
            layout.marginTop = YGValue(value: config.margin.top.toYGFloat, unit: .point)
            layout.marginLeft = YGValue(value: config.margin.left.toYGFloat, unit: .point)
            layout.marginBottom = YGValue(value: config.margin.bottom.toYGFloat, unit: .point)
            layout.marginRight = YGValue(value: config.margin.right.toYGFloat, unit: .point)
            
            // Padding
            layout.paddingTop = YGValue(value: config.padding.top.toYGFloat, unit: .point)
            layout.paddingLeft = YGValue(value: config.padding.left.toYGFloat, unit: .point)
            layout.paddingBottom = YGValue(value: config.padding.bottom.toYGFloat, unit: .point)
            layout.paddingRight = YGValue(value: config.padding.right.toYGFloat, unit: .point)
            
            // Border handling - values are already CGFloat
            if let border = config.border {
                for (edge, value) in border {
                    let cgValue = value  // Already CGFloat, no conversion needed
                    switch edge {
                    case "left": layout.borderLeftWidth = cgValue
                    case "right": layout.borderRightWidth = cgValue
                    case "top": layout.borderTopWidth = cgValue
                    case "bottom": layout.borderBottomWidth = cgValue
                    case "all": layout.borderWidth = cgValue
                    default: break
                    }
                }
            }
            
            // 5. Edge Position Properties
            if let left = config.left { layout.left = left }
            if let right = config.right { layout.right = right }
            if let top = config.top { layout.top = top }
            if let bottom = config.bottom { layout.bottom = bottom }
            
            // Update position settings to work with percentages
            if let parentView = view.superview {
                if config.position == .absolute {
                    layout.position = .absolute
                    view.frame = CGRect(origin: .zero, size: parentView.bounds.size)
                }
            }
        }

        // Force layout calculation
        view.yoga.applyLayout(preservingOrigin: true)
        
        // Debug
        print("Applied layout to \(String(describing: view.self)) - Frame: \(view.frame)")
    }
    
    private func getRootView(for view: UIView) -> UIView? {
        var current = view
        while let parent = current.superview {
            if parent == window?.rootViewController?.view {
                return current
            }
            current = parent
        }
        return nil
    }
    
    // Clean up nodes when views are removed
    internal func cleanupYogaNode(for view: UIView) {
        if let node = objc_getAssociatedObject(view, &YGNodeKey.node) as? YGNodeRef {
            YGNodeFree(node)
            objc_setAssociatedObject(view, &YGNodeKey.node, nil, .OBJC_ASSOCIATION_RETAIN)
            yogaNodes.removeValue(forKey: view.hash.description)
        }
    }
}
