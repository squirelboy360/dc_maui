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


import UIKit
import YogaKit

/**
 DCText: Native text/label component

 Expected Input Properties:
 {
   "textStyle": {
     "text": String,              // Text content to display
     "color": UInt32,            // Text color as ARGB
     "fontSize": CGFloat,        // Font size in points
     "textAlign": String,       // "left", "center", "right", "justify"
     "fontWeight": String,      // "regular", "medium", "semibold", "bold"
     "letterSpacing": CGFloat,  // Letter spacing in points
     "lineHeight": CGFloat,     // Line height multiplier
     "numberOfLines": Int,      // Max number of lines (0 for unlimited)
     "minimumScale": CGFloat,   // Minimum text scale factor
     "adjustsFontSize": Bool    // Enable dynamic text sizing
   },
   "layout": {
     // All Yoga layout properties supported
     // Text automatically sizes to content unless constrained
   }
 }

 State Changes:
 {
   "text": String              // Update text content
 }

 Automatic Behaviors:
 - Text wrapping based on available width
 - Dynamic font scaling if enabled
 - Inherited text properties from parent
 */
class DCText: DCView {
    private let label = UILabel()
    
    // Change from func to public func to make it accessible
    public func getText() -> String {
        return label.text ?? ""
    }
    
    init(viewId: String, text: String) {
        super.init(viewId: viewId)
        print("DCText init with text: \(text)")
        setupLabel(withText: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupLabel(withText text: String) {
        label.text = text
        label.numberOfLines = 0  // Allow multiline by default
        label.yoga.isEnabled = true
        addSubview(label)
        
        // Remove forced layout - let Yoga handle it
        self.yoga.isEnabled = true
        
        // Remove debug coloring
        // self.backgroundColor = .red.withAlphaComponent(0.3)  // Remove this
        // label.backgroundColor = .green.withAlphaComponent(0.3)  // Remove this
        
        // Let layout be controlled by user settings
        label.yoga.position = .relative
        label.yoga.flexGrow = 0  // Don't force growth
        label.yoga.flexShrink = 0  // Don't force shrink
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Size the label to fit the available space
        label.frame = bounds
        
        // If bounds are empty but we have text content, calculate proper size
        if bounds.size == .zero && label.text != nil && !label.text!.isEmpty {
            let maxSize = CGSize(width: UIScreen.main.bounds.width - 40, height: .greatestFiniteMagnitude)
            let neededSize = label.sizeThatFits(maxSize)
            frame.size = neededSize
            label.frame.size = neededSize
        }
        
        // Ensure text is visible
        if label.text != nil && !label.text!.isEmpty {
            // If height is too small, adjust it based on content
            let minHeight: CGFloat = 20.0
            if frame.height < minHeight {
                frame.size.height = minHeight
                label.frame.size.height = minHeight
            }
        }
        
        print("DCText layout: frame=\(frame), bounds=\(bounds)")
        print("Label layout: frame=\(label.frame), bounds=\(label.bounds)")
        print("Label text: \(label.text ?? "")")
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        super.handleStateChange(newState)
        
        if let text = newState["text"] as? String {
            label.text = text
            setNeedsLayout()
        }
        
        if let textColor = newState["textColor"] as? UInt32 {
            // Use the globally available extension method
            label.textColor = UIColor(rgb: textColor as UInt32)
        }
        
        if let color = newState["color"] as? UInt32 {
            // Use the globally available extension method
            label.textColor = UIColor(rgb: color as UInt32)
        }
        
        if let fontSize = newState["fontSize"] as? CGFloat {
            let weight = label.font?.getWeight() ?? .regular
            label.font = .systemFont(ofSize: fontSize, weight: weight)
        }
        
        if let fontWeight = newState["fontWeight"] as? String {
            let weight = UIFont.Weight(fontWeight)
            let size = label.font?.pointSize ?? 14
            label.font = .systemFont(ofSize: size, weight: weight)
        }
        
        if let alignment = newState["textAlign"] as? String {
            switch alignment {
            case "left": label.textAlignment = .left
            case "center": label.textAlignment = .center
            case "right": label.textAlignment = .right
            case "justified": label.textAlignment = .justified
            default: break
            }
        }
        
        if let numberOfLines = newState["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        }
    }
    
    override func captureCurrentState() -> [String: Any] {
        var state = super.captureCurrentState()
        
        state["text"] = label.text ?? ""
        
        if let textColor = label.textColor {
            // Use the globally available extension method
            let argb = textColor.toARGB32()
            state["textColor"] = argb
            state["color"] = argb
        }
        
        if let font = label.font {
            state["fontSize"] = font.pointSize
            state["fontWeight"] = font.getWeightString()
        }
        
        switch label.textAlignment {
        case .left: state["textAlign"] = "left"
        case .center: state["textAlign"] = "center" 
        case .right: state["textAlign"] = "right"
        case .justified: state["textAlign"] = "justified"
        default: break
        }
        
        state["numberOfLines"] = label.numberOfLines
        
        return state
    }
    
    override func applyStyle(_ style: [String: Any]) {
        print("DCText applying style: \(style)")
        super.applyStyle(style)
        
        if let textStyle = style["textStyle"] as? [String: Any] {
            print("Found textStyle: \(textStyle)")
            
            // Text content
            if let text = textStyle["text"] as? String {
                print("Setting text: \(text)")
                label.text = text
            }
            
            // Font styling
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                let weight = UIFont.Weight(textStyle["fontWeight"] as? String ?? "regular")
                if let fontFamily = textStyle["fontFamily"] as? String {
                    label.font = UIFont(name: fontFamily, size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
                } else {
                    label.font = .systemFont(ofSize: fontSize, weight: weight)
                }
            }
            
            // Color and alignment
            if let color = textStyle["color"] as? UInt32 {
                label.textColor = UIColor(rgb: color as UInt32) // Use fully qualified name if needed
            }
            if let alignment = textStyle["textAlignment"] as? String {
                switch alignment {
                case "left": label.textAlignment = .left
                case "center": label.textAlignment = .center
                case "right": label.textAlignment = .right
                case "justified": label.textAlignment = .justified
                default: label.textAlignment = .natural
                }
            }
            
            // Make sure the label fills the view bounds
            label.frame = bounds
            
            // Important: Update layout after text changes
            // This ensures proper text measurement
            self.setNeedsLayout()
            
            // Line styling
            if let lineHeight = textStyle["lineHeight"] as? CGFloat {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = lineHeight
                label.attributedText = NSAttributedString(
                    string: label.text ?? "",
                    attributes: [.paragraphStyle: paragraphStyle]
                )
            }
            if let letterSpacing = textStyle["letterSpacing"] as? CGFloat {
                label.attributedText = NSAttributedString(
                    string: label.text ?? "",
                    attributes: [.kern: letterSpacing]
                )
            }
            
            // Text size adjustment
            if let adjustsFontSize = textStyle["adjustsFontSizeToFit"] as? Bool {
                label.adjustsFontSizeToFitWidth = adjustsFontSize
                if let minSize = textStyle["minimumFontSize"] as? CGFloat {
                    label.minimumScaleFactor = minSize / (label.font.pointSize)
                }
            }
            
            // Line limits
            if let numberOfLines = textStyle["numberOfLines"] as? Int {
                label.numberOfLines = numberOfLines
            }
            
            // Text decoration
            if let decorationLine = textStyle["decorationLine"] as? String {
                var attributes: [NSAttributedString.Key: Any] = [:]
                switch decorationLine {
                case "underline":
                    attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                case "strikethrough":
                    attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                case "underlineStrikethrough":
                    attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                    attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                default: break
                }
                
                if let decorationColor = textStyle["decorationColor"] as? UInt32 {
                    attributes[.underlineColor] = UIColor(rgb: decorationColor as UInt32)
                    attributes[.strikethroughColor] = UIColor(rgb: decorationColor as UInt32)
                }
                
                if !attributes.isEmpty {
                    label.attributedText = NSAttributedString(
                        string: label.text ?? "",
                        attributes: attributes
                    )
                }
            }
            
            // Advanced text properties
            if let allowsTightening = textStyle["allowsDefaultTighteningForTruncation"] as? Bool {
                label.allowsDefaultTighteningForTruncation = allowsTightening
            }
            
            // Custom attributes
            if let attributes = textStyle["attributes"] as? [String: Any] {
                // Handle custom NSAttributedString attributes
                // This would need additional processing based on your needs
            }
        } else {
            print("No textStyle found in style")
        }
        
        // Print final state
        print("Final label text: \(label.text ?? "nil")")
        print("Final label frame: \(label.frame)")
    }
}

// Helper extension for font weights
private extension UIFont.Weight {
    init(_ string: String) {
        switch string {
        case "ultraLight": self = .ultraLight
        case "thin": self = .thin
        case "light": self = .light
        case "regular": self = .regular
        case "medium": self = .medium
        case "semibold": self = .semibold
        case "bold": self = .bold
        case "heavy": self = .heavy
        case "black": self = .black
        default: self = .regular
        }
    }
}

private enum TextAlignment: String {
    case left, center, right, justify
    
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justify: return .justified
        }
    }
}

// Add these extension methods for UIFont at the end of the file

extension UIFont {
    func getWeight() -> UIFont.Weight {
        // Try to derive the font weight from the font name
        let name = fontName.lowercased()
        
        if name.contains("bold") || name.contains("heavy") {
            return .bold
        } else if name.contains("medium") {
            return .medium
        } else if name.contains("light") {
            return .light
        } else if name.contains("thin") {
            return .thin
        } else if name.contains("semibold") {
            return .semibold
        } else {
            return .regular
        }
    }
    
    func getWeightString() -> String {
        // Convert weight to string format
        let weight = getWeight()
        
        switch weight {
        case .ultraLight: return "ultraLight"
        case .thin: return "thin"
        case .light: return "light"
        case .regular: return "regular"
        case .medium: return "medium"
        case .semibold: return "semibold"
        case .bold: return "bold"
        case .heavy: return "heavy"
        case .black: return "black"
        default: return "regular"
        }
    }
}
