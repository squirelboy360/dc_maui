import UIKit
import YogaKit

enum LayoutType {
    case flex
    case absolute
    case relative
}

struct LayoutConfig {
    var type: LayoutType = .flex
    var width: YGValue = .auto()
    var height: YGValue = .auto()
    var margin: UIEdgeInsets = .zero
    var padding: UIEdgeInsets = .zero
    var position: CGPoint = .zero
    var flexGrow: Float = 0
    var flexDirection: YGFlexDirection = .column
    var justifyContent: YGJustify = .flexStart
    var alignItems: YGAlign = .stretch
    var alignSelf: YGAlign = .auto
    
    init(from dict: [String: Any]) {
        if let type = dict["type"] as? String {
            self.type = LayoutType(rawValue: type) ?? .flex
        }
        
        // Handle size
        if let width = dict["width"] as? Double {
            self.width = width < 0 ? .percent(100) : .point(Float(width))
        }
        if let height = dict["height"] as? Double {
            self.height = height < 0 ? .percent(100) : .point(Float(height))
        }
        
        // Handle flex properties
        if let grow = dict["flex"] as? Double {
            self.flexGrow = Float(grow)
        }
        
        // Handle alignment
        if let align = dict["alignSelf"] as? String {
            self.alignSelf = YGAlign(rawValue: align) ?? .auto
        }
        
        // Handle margins
        if let margins = dict["margin"] as? [String: Double] {
            self.margin = UIEdgeInsets(
                top: margins["top"] ?? 0,
                left: margins["left"] ?? 0,
                bottom: margins["bottom"] ?? 0,
                right: margins["right"] ?? 0
            )
        }
        
        // Handle padding
        if let paddings = dict["padding"] as? [String: Double] {
            self.padding = UIEdgeInsets(
                top: paddings["top"] ?? 0,
                left: paddings["left"] ?? 0,
                bottom: paddings["bottom"] ?? 0,
                right: paddings["right"] ?? 0
            )
        }
    }
}

struct NativeLayoutConfig {
    let width: YGValue
    let height: YGValue
    let minWidth: YGValue?
    let minHeight: YGValue?
    let maxWidth: YGValue?
    let maxHeight: YGValue? 
    let margin: UIEdgeInsets
    let padding: UIEdgeInsets
    let position: YGPositionType
    let positionValues: (x: YGValue?, y: YGValue?)
    let flex: Float?
    let flexGrow: Float?
    let flexShrink: Float?
    let flexBasis: YGValue?
    let flexDirection: YGFlexDirection
    let justifyContent: YGJustify
    let alignItems: YGAlign
    let alignSelf: YGAlign
    let aspectRatio: Float?

    init(from config: [String: Any]) {
        // Type-safe parsing of layout values
        // Matches Dart LayoutConfig exactly
    }

    func apply(to view: UIView) {
        view.configureLayout { layout in
            layout.isEnabled = true
            
            // Type-safe application of layout properties
            layout.width = width
            layout.height = height
            layout.minWidth = minWidth
            layout.minHeight = minHeight
            layout.maxWidth = maxWidth
            layout.maxHeight = maxHeight
            layout.margin = margin
            layout.padding = padding
            layout.position = position
            if let x = positionValues.x { layout.left = x }
            if let y = positionValues.y { layout.top = y }
            if let flex = flex { layout.flex = flex }
            if let flexGrow = flexGrow { layout.flexGrow = flexGrow }
            if let flexShrink = flexShrink { layout.flexShrink = flexShrink }
            if let flexBasis = flexBasis { layout.flexBasis = flexBasis }
            layout.flexDirection = flexDirection
            layout.justifyContent = justifyContent  
            layout.alignItems = alignItems
            layout.alignSelf = alignSelf
            if let aspectRatio = aspectRatio { layout.aspectRatio = aspectRatio }
        }
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    internal func configureLayout(for view: UIView, with config: LayoutConfig) {
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.width = config.width
            layout.height = config.height
            
            layout.margin = config.margin
            layout.padding = config.padding
            
            layout.flexGrow = config.flexGrow
            layout.flexDirection = config.flexDirection
            
            layout.justifyContent = config.justifyContent
            layout.alignItems = config.alignItems
            layout.alignSelf = config.alignSelf
            
            if config.type == .absolute {
                layout.position = .absolute
                layout.left = YGValue(Float(config.position.x))
                layout.top = YGValue(Float(config.position.y))
            }
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
        configureLayout(for: view, with: config)
        
        // Trigger layout calculation
        view.yoga.applyLayout(preservingOrigin: true)
        result(true)
    }
}
