import UIKit
import yoga

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
    
    init(from dict: [String: Any]) {
        // Parse width/height
        if let widthStr = dict["width"] as? String {
            if (widthStr.hasSuffix("%")) {
                let value = Float(widthStr.dropLast()) ?? 100
                width = YGValue(value: value, unit: .percent)
            } else if let numWidth = Float(widthStr) {
                width = YGValue(value: numWidth, unit: .point)
            }
        }
        
        if let heightStr = dict["height"] as? String {
            if (heightStr.hasSuffix("%")) {
                let value = Float(heightStr.dropLast()) ?? 100
                height = YGValue(value: value, unit: .percent)
            } else if let numHeight = Float(heightStr) {
                height = YGValue(value: numHeight, unit: .point)
            }
        }
        
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
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    // Change from private to internal
    internal func applyYogaLayout(to view: UIView, config: LayoutConfig) {
        let node = YGNodeNew()
        defer { YGNodeFree(node) }
        
        // Direction and alignment
        YGNodeStyleSetFlexDirection(node, config.flexDirection)
        YGNodeStyleSetJustifyContent(node, config.justifyContent)
        YGNodeStyleSetAlignItems(node, config.alignItems)
        YGNodeStyleSetAlignSelf(node, config.alignSelf)
        
        // Width and height
        YGNodeStyleSetWidth(node, config.width.value)
        YGNodeStyleSetHeight(node, config.height.value)
        
        // Min/max dimensions
        if let minWidth = config.minWidth {
            YGNodeStyleSetMinWidth(node, minWidth.value)
        }
        if let minHeight = config.minHeight {
            YGNodeStyleSetMinHeight(node, minHeight.value)
        }
        if let maxWidth = config.maxWidth {
            YGNodeStyleSetMaxWidth(node, maxWidth.value)
        }
        if let maxHeight = config.maxHeight {
            YGNodeStyleSetMaxHeight(node, maxHeight.value)
        }
        
        // Flex properties
        if let flex = config.flex {
            YGNodeStyleSetFlex(node, flex)
        }
        if let flexGrow = config.flexGrow {
            YGNodeStyleSetFlexGrow(node, flexGrow)
        }
        if let flexShrink = config.flexShrink {
            YGNodeStyleSetFlexShrink(node, flexShrink)
        }
        if let flexBasis = config.flexBasis {
            YGNodeStyleSetFlexBasis(node, flexBasis.value)
        }
        
        // Position type and values
        YGNodeStyleSetPositionType(node, config.position)
        if let left = config.left {
            YGNodeStyleSetPosition(node, .left, left.value)
        }
        if let top = config.top {
            YGNodeStyleSetPosition(node, .top, top.value)
        }
        if let right = config.right {
            YGNodeStyleSetPosition(node, .right, right.value)
        }
        if let bottom = config.bottom {
            YGNodeStyleSetPosition(node, .bottom, bottom.value)
        }
        
        // Margins
        YGNodeStyleSetMargin(node, .left, Float(config.margin.left))
        YGNodeStyleSetMargin(node, .top, Float(config.margin.top))
        YGNodeStyleSetMargin(node, .right, Float(config.margin.right))
        YGNodeStyleSetMargin(node, .bottom, Float(config.margin.bottom))
        
        // Padding
        YGNodeStyleSetPadding(node, .left, Float(config.padding.left))
        YGNodeStyleSetPadding(node, .top, Float(config.padding.top))
        YGNodeStyleSetPadding(node, .right, Float(config.padding.right))
        YGNodeStyleSetPadding(node, .bottom, Float(config.padding.bottom))
        
        // Calculate layout
        YGNodeCalculateLayout(node, Float.nan, Float.nan, .LTR)
        
        // Apply calculated layout to view
        let frame = CGRect(
            x: CGFloat(YGNodeLayoutGetLeft(node)),
            y: CGFloat(YGNodeLayoutGetTop(node)),
            width: CGFloat(YGNodeLayoutGetWidth(node)),
            height: CGFloat(YGNodeLayoutGetHeight(node))
        )
        
        view.frame = frame
    }
    
    internal func applyLayout(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let view = views[viewId] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid view ID", details: nil))
            return
        }
        
        let config = LayoutConfig(from: args)
        applyYogaLayout(to: view, config: config)
        result(true)
    }
}
