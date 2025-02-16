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
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func applyYogaLayout(to view: UIView, config: LayoutConfig) {
        guard let rootNode = YGNodeNew() else { return }
        defer { YGNodeFree(rootNode) }
        
        guard let viewNode = YGNodeNew() else { return }
        defer { YGNodeFree(viewNode) }
        
        // Build the yoga node tree
        buildYogaNodeTree(for: view, node: viewNode)
        YGNodeInsertChild(rootNode, viewNode, 0)
        
        // Apply layout config to view's node
        configureYogaNode(viewNode, with: config)
        
        // Calculate layout using parent's dimensions
        let parentWidth = view.superview?.bounds.width ?? UIScreen.main.bounds.width
        let parentHeight = view.superview?.bounds.height ?? UIScreen.main.bounds.height
        
        print("Calculating layout with parent dimensions: \(parentWidth) x \(parentHeight)")
        YGNodeCalculateLayout(rootNode, Float(parentWidth), Float(parentHeight), .LTR)
        
        // Apply calculated layout recursively
        applyYogaLayout(from: viewNode, to: view)
        
        // Clean up child nodes
        cleanupYogaNodes(for: view)
    }
    
    private func buildYogaNodeTree(for view: UIView, node: YGNodeRef) {
        for subview in view.subviews {
            guard let childNode = YGNodeNew() else { continue }
            buildYogaNodeTree(for: subview, node: childNode)
            // Fix: Convert UInt32 to Int for YGNodeInsertChild
            let childCount = Int(YGNodeGetChildCount(node))
            YGNodeInsertChild(node, childNode, childCount)
        }
    }
    
    private func configureYogaNode(_ node: YGNodeRef, with config: LayoutConfig) {
        // Width/Height
        switch config.width.unit {
        case .percent:
            YGNodeStyleSetWidthPercent(node, config.width.value)
        case .point:
            YGNodeStyleSetWidth(node, config.width.value)
        case .auto:
            YGNodeStyleSetWidthAuto(node)
        default:
            break
        }
        
        switch config.height.unit {
        case .percent:
            YGNodeStyleSetHeightPercent(node, config.height.value)
        case .point:
            YGNodeStyleSetHeight(node, config.height.value)
        case .auto:
            YGNodeStyleSetHeightAuto(node)
        default:
            break
        }
        
        // Flex properties
        YGNodeStyleSetFlexDirection(node, config.flexDirection)
        YGNodeStyleSetJustifyContent(node, config.justifyContent)
        YGNodeStyleSetAlignItems(node, config.alignItems)
        YGNodeStyleSetAlignSelf(node, config.alignSelf)
        
        if let flex = config.flex {
            YGNodeStyleSetFlex(node, flex)
        }
        
        // Margins and padding
        YGNodeStyleSetMargin(node, .left, Float(config.margin.left))
        YGNodeStyleSetMargin(node, .top, Float(config.margin.top))
        YGNodeStyleSetMargin(node, .right, Float(config.margin.right))
        YGNodeStyleSetMargin(node, .bottom, Float(config.margin.bottom))
        
        YGNodeStyleSetPadding(node, .left, Float(config.padding.left))
        YGNodeStyleSetPadding(node, .top, Float(config.padding.top))
        YGNodeStyleSetPadding(node, .right, Float(config.padding.right))
        YGNodeStyleSetPadding(node, .bottom, Float(config.padding.bottom))
    }
    
    private func applyYogaLayout(from node: YGNodeRef, to view: UIView) {
        let frame = CGRect(
            x: CGFloat(YGNodeLayoutGetLeft(node)),
            y: CGFloat(YGNodeLayoutGetTop(node)),
            width: max(1, CGFloat(YGNodeLayoutGetWidth(node))),
            height: max(1, CGFloat(YGNodeLayoutGetHeight(node)))
        )
        
        print("Applying frame \(frame) to view: \(view)")
        view.frame = frame
        
        // Apply layout to children
        for (index, subview) in view.subviews.enumerated() {
            let childIndex = UInt32(index)
            if let childNode = YGNodeGetChild(node, Int(childIndex)) {
                applyYogaLayout(from: childNode, to: subview)
            }
        }
    }
    
    private func cleanupYogaNodes(for view: UIView) {
        for subview in view.subviews {
            cleanupYogaNodes(for: subview)
        }
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
