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
    // Existing properties...
    
    // Size properties
    var width: YGValue = .auto
    var height: YGValue = .auto
    var minWidth: YGValue?
    var maxWidth: YGValue?
    var minHeight: YGValue?
    var maxHeight: YGValue?
    
    // Flex properties
    var flex: Float?
    var flexGrow: Float?
    var flexShrink: Float?
    var flexBasis: YGValue?
    var flexDirection: YGFlexDirection = .column
    var flexWrap: YGWrap = .noWrap
    var gap: CGFloat = 0
    var rowGap: CGFloat = 0
    var columnGap: CGFloat = 0
    
    // Alignment & Positioning
    var justifyContent: YGJustify = .flexStart
    var alignItems: YGAlign = .stretch
    var alignSelf: YGAlign = .auto
    var alignContent: YGAlign = .flexStart
    var position: YGPositionType = .relative
    
    // Spacing
    var margin = UIEdgeInsets.zero
    var padding = UIEdgeInsets.zero
    var border = UIEdgeInsets.zero
    
    // Position coordinates
    var left: YGValue?
    var top: YGValue?
    var right: YGValue?
    var bottom: YGValue?
    
    // Additional properties
    var aspectRatio: Float?
    var display: YGDisplay = .flex
    var overflow: YGOverflow = .visible
    
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
        
        // Additional parsing
        if let wrap = dict["flexWrap"] as? String {
            flexWrap = wrap == "wrap" ? .wrap : .noWrap
        }
        
        if let gap = dict["gap"] as? CGFloat {
            self.gap = gap
            self.rowGap = gap
            self.columnGap = gap
        }
        
        if let rowGap = dict["rowGap"] as? CGFloat {
            self.rowGap = rowGap
        }
        
        if let columnGap = dict["columnGap"] as? CGFloat {
            self.columnGap = columnGap
        }
        
        if let ratio = dict["aspectRatio"] as? Float {
            self.aspectRatio = ratio
        }
        
        if let displayStr = dict["display"] as? String {
            self.display = displayStr == "none" ? .none : .flex
        }
        
        // ... Add parsing for other new properties
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

        // Configure target view
        view.configureLayout { layout in
            // Reset layout state
            layout.isEnabled = true
            
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

        // Calculate layout from root
        if let rootView = getRootView(for: view) {
            print("Calculating layout from root: \(rootView)")
            rootView.yoga.applyLayout(preservingOrigin: false)
            
            // Force UI update
            DispatchQueue.main.async {
                rootView.setNeedsLayout()
                rootView.layoutIfNeeded()
            }
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

// Add this extension to improve layout application
extension YGLayout {
    func applyConfig(_ config: LayoutConfig) {
        isEnabled = true
        
        // Dimensions
        width = config.width
        height = config.height
        minWidth = config.minWidth ?? .undefined
        maxWidth = config.maxWidth ?? .undefined
        minHeight = config.minHeight ?? .undefined
        maxHeight = config.maxHeight ?? .undefined
        
        // Flex
        flex = CGFloat(config.flex ?? 0)
        flexGrow = CGFloat(config.flexGrow ?? 0)
        flexShrink = CGFloat(config.flexShrink ?? 1)
        flexBasis = config.flexBasis ?? .auto
        flexDirection = config.flexDirection
        flexWrap = config.flexWrap
        
        // Alignment
        justifyContent = config.justifyContent
        alignItems = config.alignItems
        alignSelf = config.alignSelf
        alignContent = config.alignContent
        
        // Position
        position = config.position
        
        // Fix the position assignments
        if let leftVal = config.left {
            left = leftVal
        }
        if let topVal = config.top {
            top = topVal
        }
        if let rightVal = config.right {
            right = rightVal
        }
        if let bottomVal = config.bottom {
            bottom = bottomVal
        }
        
        // Spacing - set individual values instead of tuple assignment
        let marginValues = config.margin.toYGValue()
        marginLeft = marginValues.left
        marginTop = marginValues.top
        marginRight = marginValues.right
        marginBottom = marginValues.bottom
        
        let paddingValues = config.padding.toYGValue()
        paddingLeft = paddingValues.left
        paddingTop = paddingValues.top
        paddingRight = paddingValues.right
        paddingBottom = paddingValues.bottom
        
        // Border - use borderWidth property instead of setBorder
        if config.border != .zero {
            let borderValues = config.border.toYGValue()
            borderLeftWidth = CGFloat(borderValues.left.value)
            borderTopWidth = CGFloat(borderValues.top.value)
            borderRightWidth = CGFloat(borderValues.right.value)
            borderBottomWidth = CGFloat(borderValues.bottom.value)
        }
        
        // Additional
        if let ratio = config.aspectRatio {
            aspectRatio = CGFloat(ratio)
        }
        display = config.display
        overflow = config.overflow
    }
}

// First add this extension for UIEdgeInsets
extension UIEdgeInsets {
    func toYGValue() -> (left: YGValue, top: YGValue, right: YGValue, bottom: YGValue) {
        return (
            YGValue(value: Float(left), unit: .point),
            YGValue(value: Float(top), unit: .point),
            YGValue(value: Float(right), unit: .point),
            YGValue(value: Float(bottom), unit: .point)
        )
    }
}

// Helper extension for color conversion
extension UIColor {
    convenience init?(from hexString: String?) {
        guard let hexString = hexString else { return nil }
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
