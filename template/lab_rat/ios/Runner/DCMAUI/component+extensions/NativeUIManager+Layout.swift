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
        // Store original parent dimensions
        let parentView = view.superview
        let originalParentFrame = parentView?.frame
        
        // Enable yoga
        view.yoga.isEnabled = true
        parentView?.yoga.isEnabled = true
        
        // If using percentage height/width, ensure parent has valid dimensions
        if config.height.unit == .percent || config.width.unit == .percent {
            if let parent = parentView {
                // Preserve parent's dimensions
                if parent.frame.height == 0 {
                    parent.frame.size.height = originalParentFrame?.height ?? UIScreen.main.bounds.height
                }
                if parent.frame.width == 0 {
                    parent.frame.size.width = originalParentFrame?.width ?? UIScreen.main.bounds.width
                }
                
                // Force parent layout update
                parent.yoga.applyLayout(preservingOrigin: true)
            }
        }

        // Configure view layout
        view.configureLayout { layout in
            // Existing layout configuration...
            layout.isEnabled = true
            
            // Set dimensions with parent context
            if config.width.unit == .percent {
                layout.width = YGValue(value: config.width.value, unit: .percent)
                print("Setting percentage width: \(config.width.value)% of parent width: \(parentView?.frame.width ?? 0)")
            }
            
            if config.height.unit == .percent {
                layout.height = YGValue(value: config.height.value, unit: .percent)
                print("Setting percentage height: \(config.height.value)% of parent height: \(parentView?.frame.height ?? 0)")
            }
            
            // Rest of your existing layout configuration...
            // Set dimensions
            switch config.width.unit {
            case .percent:
                layout.width = YGValue(value: config.width.value, unit: .percent)
                print("Setting width: \(config.width.value)%")
            case .point:
                layout.width = YGValue(value: config.width.value, unit: .point)
                print("Setting width: \(config.width.value)pt")
            case .auto:
                layout.width = .auto
                print("Setting auto width")
            default:
                layout.width = .auto
            }
            
            switch config.height.unit {
            case .percent:
                layout.height = YGValue(value: config.height.value, unit: .percent)
                print("Setting height: \(config.height.value)%")
            case .point:
                layout.height = YGValue(value: config.height.value, unit: .point)
                print("Setting height: \(config.height.value)pt")
            case .auto:
                layout.height = .auto
                print("Setting auto height")
            default:
                layout.height = .auto
            }

            // Core layout properties
            layout.flexDirection = config.flexDirection
            layout.justifyContent = config.justifyContent
            layout.alignItems = config.alignItems
            layout.position = config.position

            if let flex = config.flex {
                layout.flex = CGFloat(flex)
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
        }
        
        // Calculate layout
        if let rootView = getRootView(for: view) {
            rootView.yoga.applyLayout(preservingOrigin: false)
            
            // Verify dimensions after layout
            print("Final view dimensions - width: \(view.frame.width), height: \(view.frame.height)")
            print("Parent dimensions - width: \(parentView?.frame.width ?? 0), height: \(parentView?.frame.height ?? 0)")
        }
    }

    internal func getRootView(for view: UIView) -> UIView? {
        var current = view
        while let parent = current.superview {
            if !parent.yoga.isEnabled {
                return current
            }
            current = parent
        }
        return current
    }
}
