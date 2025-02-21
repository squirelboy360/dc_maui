import UIKit
import YogaKit  

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
    var border: [String: Float]?

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
                top: margins["top"] ?? 0,
                left: margins["left"] ?? 0,
                bottom: margins["bottom"] ?? 0,
                right: margins["right"] ?? 0
            )
        }
        
        if let paddings = dict["padding"] as? [String: Double] {
            padding = UIEdgeInsets(
                top: paddings["top"] ?? 0,
                left: paddings["left"] ?? 0,
                bottom: paddings["bottom"] ?? 0,
                right: paddings["right"] ?? 0
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
        if let borderDict = dict["border"] as? [String: Double] {
            border = borderDict.mapValues { Float($0) }
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
        // 1. Get or create yoga node
        guard let node = getYogaNode(for: view) else { return }
        view.yoga.isEnabled = true
        
        // 2. Configure parent
        if let parentView = view.superview {
            guard let parentNode = getYogaNode(for: parentView) else { return }
            parentView.yoga.isEnabled = true
            
            // Parent dimensions for percentage calculations
            parentView.yoga.width = YGValue(value: Float(parentView.bounds.width), unit: .point)
            parentView.yoga.height = YGValue(value: Float(parentView.bounds.height), unit: .point)
            
            // Attach child to parent node
            YGNodeInsertChild(parentNode, node, UInt32(parentView.subviews.firstIndex(of: view) ?? 0))
        }

        // 3. Configure node
        view.configureLayout { layout in
            // Position type 
            layout.position = config.position
            
            // Dimensions with percentage handling
            layout.width = config.width
            if config.width.unit == .percent {
                if let parentView = view.superview {
                    layout.maxWidth = YGValue(value: Float(parentView.bounds.width), unit: .point)
                }
            }
            
            layout.height = config.height
            if config.height.unit == .percent {
                if let parentView = view.superview {
                    layout.maxHeight = YGValue(value: Float(parentView.bounds.height), unit: .point)  
                }
            }
            
            // Rest of the layout configuration remains the same
            // ...existing code...
        }
        
        // 4. Calculate layout from root
        if let rootView = getRootView(for: view) {
            rootView.yoga.applyLayout(preservingOrigin: true)
        }
        
        // 5. Persist layout
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // Debug
        print("Layout applied to \(view) - Frame: \(view.frame)")
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
