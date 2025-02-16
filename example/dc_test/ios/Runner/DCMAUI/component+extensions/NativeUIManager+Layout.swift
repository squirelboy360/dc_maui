import UIKit
import YogaKit

// Helper functions to create YGValue
extension YGValue {
    static func point(_ value: Float) -> YGValue {
        return YGValue(value: value, unit: .point)
    }
    
    static func percent(_ value: Float) -> YGValue {
        return YGValue(value: value, unit: .percent)
    }
    
    static func auto() -> YGValue {
        return YGValue(value: Float.nan, unit: .auto)
    }
}

enum LayoutType: String {
    case flex
    case absolute
    case relative
}

struct LayoutConfig {
    var width: YGValue = .auto()
    var height: YGValue = .auto()
    var margin: YGEdgeInsets = .zero
    var padding: YGEdgeInsets = .zero
    var position: YGPositionType = .relative
    var positionLeft: YGValue?
    var positionTop: YGValue?
    var flexGrow: Float = 0
    var flexDirection: YGFlexDirection = .column
    var justifyContent: YGJustify = .flexStart
    var alignItems: YGAlign = .stretch
    var alignSelf: YGAlign = .auto
    
    init(from dict: [String: Any]) {
        // Handle width/height
        if let width = dict["width"] as? String {
            if width.hasSuffix("%") {
                let value = Float(width.dropLast()) ?? 100
                self.width = .percent(value)
            } else if let numWidth = Float(width) {
                self.width = .point(numWidth)
            }
        } else if let width = dict["width"] as? Double {
            self.width = width < 0 ? .percent(100) : .point(Float(width))
        }
        
        // Similar for height...
        if let height = dict["height"] as? String {
            if height.hasSuffix("%") {
                let value = Float(height.dropLast()) ?? 100
                self.height = .percent(value)
            } else if let numHeight = Float(height) {
                self.height = .point(numHeight)
            }
        } else if let height = dict["height"] as? Double {
            self.height = height < 0 ? .percent(100) : .point(Float(height))
        }
        
        // Position type
        if let positionStr = dict["position"] as? String {
            self.position = positionStr == "absolute" ? .absolute : .relative
        }
        
        // Handle position values if absolute
        if position == .absolute {
            if let left = dict["left"] as? Double {
                self.positionLeft = .point(Float(left))
            }
            if let top = dict["top"] as? Double {
                self.positionTop = .point(Float(top))
            }
        }
        
        // The rest remains similar but uses proper Yoga types
        // ...
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
            
            // Width and height
            layout.width = config.width
            layout.height = config.height
            
            // Margins
            layout.marginTop = YGValue(value: Float(config.margin.top), unit: .point)
            layout.marginLeft = YGValue(value: Float(config.margin.left), unit: .point)
            layout.marginBottom = YGValue(value: Float(config.margin.bottom), unit: .point)
            layout.marginRight = YGValue(value: Float(config.margin.right), unit: .point)
            
            // Padding
            layout.paddingTop = YGValue(value: Float(config.padding.top), unit: .point)
            layout.paddingLeft = YGValue(value: Float(config.padding.left), unit: .point)
            layout.paddingBottom = YGValue(value: Float(config.padding.bottom), unit: .point)
            layout.paddingRight = YGValue(value: Float(config.padding.right), unit: .point)
            
            // Flex properties
            layout.flexGrow = config.flexGrow
            layout.flexDirection = config.flexDirection
            
            // Alignment
            layout.justifyContent = config.justifyContent
            layout.alignItems = config.alignItems
            layout.alignSelf = config.alignSelf
            
            // Position type
            if config.position == .absolute {
                layout.position = .absolute
                if let left = config.positionLeft {
                    layout.left = left
                }
                if let top = config.positionTop {
                    layout.top = top
                }
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
        
        view.yoga.applyLayout(preservingOrigin: true)
        result(true)
    }
}
