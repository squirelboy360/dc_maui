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
    // Add this helper method at the top of the extension
    private func getRootView(for view: UIView) -> UIView? {
        var current = view
        while let parent = current.superview {
            if parent == window?.rootViewController?.view {
                return current
            }
            current = parent
        }
        return view
    }

    internal func applyYogaLayout(to view: UIView, config: LayoutConfig) {
    print("Applying layout to view: \(view)")
    
    let parentView = view.superview
    view.yoga.isEnabled = true
    parentView?.yoga.isEnabled = true
    
    // Configure the layout
    view.configureLayout { layout in
        layout.isEnabled = true
        layout.position = config.position
        
        // Set dimensions first
        if config.width.unit != .undefined {
            layout.width = config.width
            print("Setting width: \(config.width.value) \(config.width.unit)")
        }
        if config.height.unit != .undefined {
            layout.height = config.height
            print("Setting height: \(config.height.value) \(config.height.unit)")
        }
        
        // Handle absolute positioning
        if config.position == .absolute {
            layout.position = .absolute
            layout.display = .flex
            
            // Set position values
            if let left = config.left {
                layout.left = left
                print("Set left: \(left.value)")
            }
            if let right = config.right {
                layout.right = right
                print("Set right: \(right.value)")
            }
            if let top = config.top {
                layout.top = top
                print("Set top: \(top.value)")
            }
            if let bottom = config.bottom {
                layout.bottom = bottom
                print("Set bottom: \(bottom.value)")
            }
        }
        
        // Set other layout properties
        layout.flexDirection = config.flexDirection
        layout.justifyContent = config.justifyContent
        layout.alignItems = config.alignItems
        layout.alignSelf = config.alignSelf
        
        if let flex = config.flex {
            layout.flex = CGFloat(flex)
        }
        if let flexGrow = config.flexGrow {
            layout.flexGrow = CGFloat(flexGrow)
        }
        if let flexShrink = config.flexShrink {
            layout.flexShrink = CGFloat(flexShrink)
        }
        if let flexBasis = config.flexBasis {
            layout.flexBasis = flexBasis
        }
        if let display = config.display {
            layout.display = display
        }
        
        // Set margins
        if config.margin != .zero {
            layout.marginLeft = YGValue(value: Float(config.margin.left), unit: .point)
            layout.marginTop = YGValue(value: Float(config.margin.top), unit: .point)
            layout.marginRight = YGValue(value: Float(config.margin.right), unit: .point)
            layout.marginBottom = YGValue(value: Float(config.margin.bottom), unit: .point)
        }
        
        // Set padding
        if config.padding != .zero {
            layout.paddingLeft = YGValue(value: Float(config.padding.left), unit: .point)
            layout.paddingTop = YGValue(value: Float(config.padding.top), unit: .point)
            layout.paddingRight = YGValue(value: Float(config.padding.right), unit: .point)
            layout.paddingBottom = YGValue(value: Float(config.padding.bottom), unit: .point)
        }
        
        // Set min/max dimensions
        if let minWidth = config.minWidth {
            layout.minWidth = minWidth
        }
        if let minHeight = config.minHeight {
            layout.minHeight = minHeight
        }
        if let maxWidth = config.maxWidth {
            layout.maxWidth = maxWidth
        }
        if let maxHeight = config.maxHeight {
            layout.maxHeight = maxHeight
        }
        
        // Set border
        if let border = config.border {
            border.forEach { edge, value in
                switch edge {
                case "left": layout.borderLeftWidth = CGFloat(value)
                case "right": layout.borderRightWidth = CGFloat(value)
                case "top": layout.borderTopWidth = CGFloat(value)
                case "bottom": layout.borderBottomWidth = CGFloat(value)
                default: break
                }
            }
        }
    }
    
    // Force layout calculation
    if let rootView = getRootView(for: view) {
        rootView.yoga.applyLayout(preservingOrigin: true)
        
        if config.position == .absolute {
            parentView?.bringSubviewToFront(view)
            view.layer.zPosition = 1000
            
            // Get current frame values
            let currentFrame = view.frame
            
            // Calculate new frame
            let x = CGFloat(view.yoga.left.value)
            let y = CGFloat(view.yoga.top.value)
            let width = CGFloat(view.yoga.width.value)
            let height = CGFloat(view.yoga.height.value)
            
            // Only update if we have valid values
            if !x.isNaN && !y.isNaN && !width.isNaN && !height.isNaN {
                let newFrame = CGRect(x: x, y: y, width: width, height: height)
                if newFrame != currentFrame {
                    view.frame = newFrame
                    print("Updated absolute frame to: \(newFrame)")
                }
            }
        }
    }
    
    view.setNeedsLayout()
    view.layoutIfNeeded()
}
}