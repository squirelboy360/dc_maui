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
        
        // Handle all YogaValues with proper unit handling
        func applyYogaValue(_ dict: [String: Any]?, to property: ReferenceWritableKeyPath<YGLayout, YGValue>) {
            guard let dict = dict,
                  let value = dict["value"] as? Double,
                  let unitStr = dict["unit"] as? String else { return }
            
            let unit: YGUnit = {
                switch unitStr {
                case "percent": return .percent
                case "auto": return .auto
                case "point": return .point
                default: return .point
                }
            }()
            
            self[keyPath: property] = YGValue(value: Float(value), unit: unit)
        }
        
        // Dimensions
        if let widthDict = config["width"] as? [String: Any] {
            let value = Float(widthDict["value"] as? Double ?? 0)
            let unit = widthDict["unit"] as? String == "percent" ? YGUnit.percent : YGUnit.point
            self.width = YGValue(value: value, unit: unit)
        }
        applyYogaValue(config["height"] as? [String: Any], to: \.height)
        applyYogaValue(config["minWidth"] as? [String: Any], to: \.minWidth)
        applyYogaValue(config["minHeight"] as? [String: Any], to: \.minHeight)
        applyYogaValue(config["maxWidth"] as? [String: Any], to: \.maxWidth)
        applyYogaValue(config["maxHeight"] as? [String: Any], to: \.maxHeight)
        applyYogaValue(config["flexBasis"] as? [String: Any], to: \.flexBasis)
        
        // Position
        if let position = config["position"] as? String {
            self.position = {
                switch position {
                case "absolute": return .absolute
                case "relative": return .relative
                default: return .relative
                }
            }()
        }
        
        // Handle positionValues EdgeValues
        if let positionValues = config["positionValues"] as? [String: Any] {
            applyPositionValues(positionValues)
        }
        
        // Display
        if let display = config["display"] as? String {
            self.display = display == "none" ? .none : .flex
        }
        
        // Overflow
        if let overflow = config["overflow"] as? String {
            self.overflow = {
                switch overflow {
                case "visible": return .visible
                case "hidden": return .hidden
                case "scroll": return .scroll
                default: return .visible
                }
            }()
        }
        
        // Flex properties
        if let flex = config["flex"] as? Double { self.flex = CGFloat(flex) }
        if let flexGrow = config["flexGrow"] as? Double { self.flexGrow = CGFloat(flexGrow) }
        if let flexShrink = config["flexShrink"] as? Double { self.flexShrink = CGFloat(flexShrink) }
        
        // Direction and Wrap
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
                case "nowrap": return .noWrap
                default: return .noWrap
                }
            }()
        }
        
        // Alignment
        if let alignSelf = config["alignSelf"] as? String {
            self.alignSelf = YGAlign(cssValue: alignSelf)
        }
        if let alignItems = config["alignItems"] as? String {
            self.alignItems = YGAlign(cssValue: alignItems)
        }
        if let alignContent = config["alignContent"] as? String {
            self.alignContent = YGAlign(cssValue: alignContent)
        }
        if let justify = config["justifyContent"] as? String {
            self.justifyContent = YGJustify(cssValue: justify)
        }
        
        if let aspectRatio = config["aspectRatio"] as? Double {
            self.aspectRatio = CGFloat(aspectRatio)
        }
        
        // Keep working spacing
        if let marginDict = config["margin"] as? [String: Any] {
            if let value = marginDict["value"] as? Double,
               let unit = marginDict["unit"] as? String {
                let yogaValue = YGValue(Float(value), unit == "percent" ? .percent : .point)
                self.margin = yogaValue
            }
        }
    }
    
    func applySpacing(_ config: [String: Any]) {
        // Apply EdgeValues for margin and padding
        func applyEdgeValues(_ values: [String: Any], prefix: String) {
            // Handle "all" value first
            if let all = values[""] as? [String: Any] {
                applyYogaValue(all, prefix == "margin" ? \.margin : \.padding)
            }
            
            // Handle individual edges
            if let left = values["Left"] as? [String: Any] {
                applyYogaValue(left, prefix == "margin" ? \.marginLeft : \.paddingLeft)
            }
            if let right = values["Right"] as? [String: Any] {
                applyYogaValue(right, prefix == "margin" ? \.marginRight : \.paddingRight)
            }
            if let top = values["Top"] as? [String: Any] {
                applyYogaValue(top, prefix == "margin" ? \.marginTop : \.paddingTop)
            }
            if let bottom = values["Bottom"] as? [String: Any] {
                applyYogaValue(bottom, prefix == "margin" ? \.marginBottom : \.paddingBottom)
            }
            if let start = values["Start"] as? [String: Any] {
                applyYogaValue(start, prefix == "margin" ? \.marginStart : \.paddingStart)
            }
            if let end = values["End"] as? [String: Any] {
                applyYogaValue(end, prefix == "margin" ? \.marginEnd : \.paddingEnd)
            }
            if let horizontal = values["Horizontal"] as? [String: Any] {
                applyYogaValue(horizontal, prefix == "margin" ? \.marginHorizontal : \.paddingHorizontal)
            }
            if let vertical = values["Vertical"] as? [String: Any] {
                applyYogaValue(vertical, prefix == "margin" ? \.marginVertical : \.paddingVertical)
            }
        }
        
        if let margin = config["margin"] as? [String: Any] {
            applyEdgeValues(margin, prefix: "margin")
        }
        if let padding = config["padding"] as? [String: Any] {
            applyEdgeValues(padding, prefix: "padding")
        }
    }
    
    private func applyYogaValue(_ dict: [String: Any], _ property: ReferenceWritableKeyPath<YGLayout, YGValue>) {
        if let value = dict["value"] as? Double,
           let unitStr = dict["unit"] as? String {
            let unit: YGUnit = {
                switch unitStr {
                case "percent": return .percent
                case "auto": return .auto
                default: return .point
                }
            }()
            self[keyPath: property] = YGValue(value: Float(value), unit: unit)
        }
    }
    
    private func applyPositionValues(_ values: [String: Any]) {
        // Apply position edge values
        if let left = values["Left"] as? [String: Any] { applyYogaValue(left, \.left) }
        if let right = values["Right"] as? [String: Any] { applyYogaValue(right, \.right) }
        if let top = values["Top"] as? [String: Any] { applyYogaValue(top, \.top) }
        if let bottom = values["Bottom"] as? [String: Any] { applyYogaValue(bottom, \.bottom) }
        if let start = values["Start"] as? [String: Any] { applyYogaValue(start, \.start) }
        if let end = values["End"] as? [String: Any] { applyYogaValue(end, \.end) }
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
