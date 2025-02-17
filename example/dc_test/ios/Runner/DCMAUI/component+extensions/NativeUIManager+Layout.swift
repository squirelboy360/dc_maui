import UIKit
import YogaKit  // Change to YogaKit

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
        // Enable yoga for this view and all parent views
        var currentView: UIView? = view
        while currentView != nil {
            currentView?.yoga.isEnabled = true
            currentView = currentView?.superview
        }

        // Configure root view (superview) if it exists
        if let superview = view.superview {
            superview.yoga.isEnabled = true
            superview.yoga.width = YGValue(value: Float(superview.bounds.width), unit: .point)
            superview.yoga.height = YGValue(value: Float(superview.bounds.height), unit: .point)
            superview.yoga.flexDirection = .column
            superview.yoga.alignItems = .stretch // Let children take full width
        }

        // Configure the target view
        view.configureLayout { layout in
            // Reset existing layout
            layout.display = .flex
            
            // Set dimensions with proper units
            if config.width.unit == .percent {
                layout.width = YGValue(value: config.width.value, unit: .percent)
                print("Setting percent width: \(config.width.value)")
            } else if config.width.unit == .point {
                layout.width = YGValue(value: config.width.value, unit: .point)
                print("Setting point width: \(config.width.value)")
            } else {
                layout.width = .auto
                print("Setting auto width")
            }

            if config.height.unit == .percent {
                layout.height = YGValue(value: config.height.value, unit: .percent)
                print("Setting percent height: \(config.height.value)")
            } else if config.height.unit == .point {
                layout.height = YGValue(value: config.height.value, unit: .point)
                print("Setting point height: \(config.height.value)")
            } else {
                layout.height = .auto
                print("Setting auto height")
            }

            // Set core layout properties
            layout.flexDirection = config.flexDirection
            layout.justifyContent = config.justifyContent
            layout.alignItems = config.alignItems
            layout.position = config.position

            if let flex = config.flex {
                layout.flex = CGFloat(flex)
            }

            // Set margins explicitly
            layout.marginLeft = YGValue(value: Float(config.margin.left), unit: .point)
            layout.marginTop = YGValue(value: Float(config.margin.top), unit: .point)
            layout.marginRight = YGValue(value: Float(config.margin.right), unit: .point)
            layout.marginBottom = YGValue(value: Float(config.margin.bottom), unit: .point)

            // Set padding explicitly
            layout.paddingLeft = YGValue(value: Float(config.padding.left), unit: .point)
            layout.paddingTop = YGValue(value: Float(config.padding.top), unit: .point)
            layout.paddingRight = YGValue(value: Float(config.padding.right), unit: .point)
            layout.paddingBottom = YGValue(value: Float(config.padding.bottom), unit: .point)
        }

        // Enable yoga for all child views
        for subview in view.subviews {
            subview.yoga.isEnabled = true
        }

        // Calculate and apply layout from the highest yoga-enabled ancestor
        var rootView = view
        while let parent = rootView.superview, parent.yoga.isEnabled {
            rootView = parent
        }
        
        print("Calculating layout from root view: \(rootView)")
        rootView.yoga.applyLayout(preservingOrigin: false)
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

    // Add this helper method
    private func storeLayoutConfig(_ config: LayoutConfig, for viewId: String) {
        layoutConfigs[viewId] = config
    }
}
