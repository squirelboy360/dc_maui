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
     
     func getText() -> String {
         return label.text ?? ""
     }
    
    init(viewId: String, text: String) {
        super.init(viewId: viewId)
        setupLabel(withText: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupLabel(withText text: String) {
        label.text = text
        label.numberOfLines = 0
        label.yoga.isEnabled = true
        addSubview(label)
        
        // Make label fill parent
        label.yoga.position = .absolute
        label.yoga.left = YGValue.zero
        label.yoga.top = YGValue.zero
        label.yoga.right = YGValue.zero
        label.yoga.bottom = YGValue.zero
    }
    
    override func handleStateChange(_ newState: [String: Any]) {
        if let text = newState["text"] as? String {
            label.text = text
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let textStyle = style["textStyle"] as? [String: Any] {
            if let color = textStyle["color"] as? UInt32 {
                label.textColor = UIColor(rgb: color)
            }
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                label.font = .systemFont(ofSize: fontSize)
            }
            if let alignment = textStyle["textAlign"] as? String {
                label.textAlignment = TextAlignment(rawValue: alignment)?.nsTextAlignment ?? .left
            }
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
