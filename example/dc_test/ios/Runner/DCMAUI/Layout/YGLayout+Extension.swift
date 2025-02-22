/*
 BSD 3-Clause License

Copyright (c) 2025, Tahiru Agbanwa

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import YogaKit
import yoga

extension YGLayout {
    // CSS-like shorthand properties
    func applyFlexbox(_ config: [String: Any]) {
        print("Applying flexbox config: \(config)")
        
        // Dimensions
        for (key, value) in [
            "width": width,
            "height": height,
            "minWidth": minWidth,
            "minHeight": minHeight,
            "maxWidth": maxWidth,
            "maxHeight": maxHeight,
            "flexBasis": flexBasis
        ] {
            if let valueDict = config[key] as? [String: Any] {
                let value = Float(valueDict["value"] as? Double ?? 0)
                let unit = valueDict["unit"] as? String == "percent" ? YGUnit.percent : YGUnit.point
                self.setValue(YGValue(value: value, unit: unit), forKey: key)
            }
        }
        
        // Display & Overflow
        if let display = config["display"] as? String {
            self.display = display == "none" ? .none : .flex
        }
        
        if let overflow = config["overflow"] as? String {
            switch overflow {
            case "visible": self.overflow = .visible
            case "hidden": self.overflow = .hidden
            case "scroll": self.overflow = .scroll
            default: break
            }
        }
        
        // Position
        if let position = config["position"] as? String {
            self.position = position == "absolute" ? .absolute : .relative
        }
        
        // Flex properties
        if let flex = config["flex"] as? Double { self.flex = CGFloat(flex) }
        if let flexGrow = config["flexGrow"] as? Double { self.flexGrow = CGFloat(flexGrow) }
        if let flexShrink = config["flexShrink"] as? Double { self.flexShrink = CGFloat(flexShrink) }
        
        // Direction & Wrapping
        if let direction = config["flexDirection"] as? String {
            self.flexDirection = {
                switch direction {
                case "row": return .row
                case "row-reverse": return .rowReverse
                case "column": return .column
                case "column-reverse": return .columnReverse
                default: return .column
                }
            }()
        }
        
        if let wrap = config["flexWrap"] as? String {
            self.flexWrap = {
                switch wrap {
                case "wrap": return .wrap
                case "wrap-reverse": return .wrapReverse
                default: return .noWrap
                }
            }()
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
        
        if let alignContent = config["alignContent"] as? String {
            self.alignContent = YGAlign(cssValue: alignContent)
        }
        
        // Aspect ratio
        if let aspectRatio = config["aspectRatio"] as? Double {
            self.aspectRatio = CGFloat(aspectRatio)
        }
    }
    
    // CSS-style margin/padding/position
    func applySpacing(_ config: [String: Any]) {
        print("Applying spacing config: \(config)")
        
        // Handle EdgeValues format from Dart
        func applyEdgeValues(_ values: [String: Any], to property: String) {
            if let all = values[""] as? [String: Any] {
                let value = Float(all["value"] as? Double ?? 0)
                let unit = all["unit"] as? String == "percent" ? YGUnit.percent : YGUnit.point
                let yogaValue = YGValue(value: value, unit: unit)
                
                switch property {
                case "margin":
                    margin = yogaValue
                case "padding":
                    padding = yogaValue
                default: break
                }
            } else {
                // Handle individual edges
                let edges = ["Left", "Right", "Top", "Bottom"]
                for edge in edges {
                    if let edgeValue = values[edge] as? [String: Any] {
                        let value = Float(edgeValue["value"] as? Double ?? 0)
                        let unit = edgeValue["unit"] as? String == "percent" ? YGUnit.percent : YGUnit.point
                        let yogaValue = YGValue(value: value, unit: unit)
                        
                        switch property {
                        case "margin":
                            setValue(yogaValue, forKey: "margin\(edge)")
                        case "padding":
                            setValue(yogaValue, forKey: "padding\(edge)")
                        default: break
                        }
                    }
                }
            }
        }
        
        if let margin = config["margin"] as? [String: Any] {
            applyEdgeValues(margin, to: "margin")
        }
        
        if let padding = config["padding"] as? [String: Any] {
            applyEdgeValues(padding, to: "padding")
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
