import YogaKit

extension YGLayout {
    // CSS-like shorthand properties
    func applyFlexbox(_ config: [String: Any]) {
        // Flex
        if let flex = config["flex"] as? CGFloat { self.flex = flex }
        if let flexGrow = config["flexGrow"] as? CGFloat { self.flexGrow = flexGrow }
        if let flexShrink = config["flexShrink"] as? CGFloat { self.flexShrink = flexShrink }
        if let flexBasis = config["flexBasis"] as? YGValue { self.flexBasis = flexBasis }
        
        // Direction
        if let direction = config["flexDirection"] as? String {
            switch direction {
            case "row": flexDirection = .row
            case "row-reverse": flexDirection = .rowReverse
            case "column": flexDirection = .column
            case "column-reverse": flexDirection = .columnReverse
            default: break
            }
        }
        
        // Wrapping
        if let wrap = config["flexWrap"] as? String {
            switch wrap {
            case "wrap": flexWrap = .wrap
            case "nowrap": flexWrap = .noWrap
            case "wrap-reverse": flexWrap = .wrapReverse
            default: break
            }
        }
        
        // Alignment
        if let justifyContent = config["justifyContent"] as? String {
            self.justifyContent = YGJustify(cssValue: justifyContent)
        }
        
        if let alignItems = config["alignItems"] as? String {
            self.alignItems = YGAlign(cssValue: alignItems)
        }
        
        if let alignSelf = config["alignSelf"] as? String {
            self.alignSelf = YGAlign(cssValue: alignSelf)
        }
        
        // Spacing
        if let gap = config["gap"] as? CGFloat {
            self.gap = gap
        }
    }
    
    // CSS-style margin/padding/position
    func applySpacing(_ config: [String: Any]) {
        // Margins
        if let margin = config["margin"] {
            if let value = margin as? CGFloat {
                // Single value for all sides
                marginTop = YGValue(value)
                marginRight = YGValue(value)
                marginBottom = YGValue(value)
                marginLeft = YGValue(value)
            } else if let values = margin as? [String: Any] {
                // Individual sides
                if let top = values["top"] as? CGFloat { marginTop = YGValue(top) }
                if let right = values["right"] as? CGFloat { marginRight = YGValue(right) }
                if let bottom = values["bottom"] as? CGFloat { marginBottom = YGValue(bottom) }
                if let left = values["left"] as? CGFloat { marginLeft = YGValue(left) }
            }
        }
        
        // Padding (similar to margin)
        if let padding = config["padding"] {
            if let value = padding as? CGFloat {
                paddingTop = YGValue(value)
                paddingRight = YGValue(value)
                paddingBottom = YGValue(value)
                paddingLeft = YGValue(value)
            } else if let values = padding as? [String: Any] {
                if let top = values["top"] as? CGFloat { paddingTop = YGValue(top) }
                if let right = values["right"] as? CGFloat { paddingRight = YGValue(right) }
                if let bottom = values["bottom"] as? CGFloat { paddingBottom = YGValue(bottom) }
                if let left = values["left"] as? CGFloat { paddingLeft = YGValue(left) }
            }
        }
        
        // Position
        if let position = config["position"] as? String {
            self.position = position == "absolute" ? .absolute : .relative
        }
    }
}

// CSS value helpers
extension YGJustify {
    init(cssValue: String) {
        switch cssValue {
        case "flex-start": self = .flexStart
        case "flex-end": self = .flexEnd
        case "center": self = .center
        case "space-between": self = .spaceBetween
        case "space-around": self = .spaceAround
        case "space-evenly": self = .spaceEvenly
        default: self = .flexStart
        }
    }
}

extension YGAlign {
    init(cssValue: String) {
        switch cssValue {
        case "flex-start": self = .flexStart
        case "flex-end": self = .flexEnd
        case "center": self = .center
        case "stretch": self = .stretch
        case "baseline": self = .baseline
        case "space-between": self = .spaceBetween
        case "space-around": self = .spaceAround
        default: self = .auto
        }
    }
}
