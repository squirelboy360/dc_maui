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

class DCView: UIView, DCComponent {
    let viewId: String
    
    init(viewId: String) {
        self.viewId = viewId
        super.init(frame: .zero)
        setupDefaults()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func setupDefaults() {
        self.yoga.isEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func handleStateChange(_ newState: [String: Any]) {
        // Apply generic state changes that might affect any view
        if let opacity = newState["opacity"] as? CGFloat {
            self.alpha = opacity
        }
        if let hidden = newState["hidden"] as? Bool {
            self.isHidden = hidden
        }
        if let alpha = newState["alpha"] as? CGFloat {
            self.alpha = alpha
        }
        if let background = newState["backgroundColor"] as? UInt32 {
            self.backgroundColor = UIColor(rgb: background as UInt32)
        }
        if let cornerRadius = newState["cornerRadius"] as? CGFloat {
            self.layer.cornerRadius = cornerRadius
        }
        if let transform = newState["transform"] as? [String: Any] {
            applyTransformFromState(transform)
        }
    }
    
    private func applyTransformFromState(_ transform: [String: Any]) {
        var transformations = CGAffineTransform.identity
        
        if let scale = transform["scale"] as? CGFloat {
            transformations = transformations.scaledBy(x: scale, y: scale)
        }
        
        if let rotation = transform["rotation"] as? CGFloat {
            transformations = transformations.rotated(by: rotation)
        }
        
        if let translation = transform["translation"] as? [String: CGFloat] {
            let x = translation["x"] ?? 0
            let y = translation["y"] ?? 0
            transformations = transformations.translatedBy(x: x, y: y)
        }
        
        self.transform = transformations
    }
    
    func applyStyle(_ style: [String: Any]) {
        print("Applying style to view: \(viewId)")
        print("Style config: \(style)")
        
        // Handle layout first
        if let layout = style["layout"] as? [String: Any] {
            yoga.isEnabled = true
            yoga.applyFlexbox(layout)
            yoga.applySpacing(layout)
        }
        
        // Handle visual properties directly just like backgroundColor
        if let backgroundColor = style["backgroundColor"] as? UInt32 {
            self.backgroundColor = UIColor(rgb: backgroundColor as UInt32)
        }
        if let cornerRadius = style["cornerRadius"] as? CGFloat {
            self.layer.cornerRadius = cornerRadius
        }
        if let alpha = style["alpha"] as? CGFloat {
            self.alpha = alpha
        }
        if let opacity = style["opacity"] as? Float {
            self.layer.opacity = opacity
        }
        if let shadowColor = style["shadowColor"] as? UInt32 {
            self.layer.shadowColor = UIColor(rgb: shadowColor as UInt32).cgColor
        }
        if let shadowOpacity = style["shadowOpacity"] as? Float {
            self.layer.shadowOpacity = shadowOpacity
        }
        if let shadowOffset = style["shadowOffset"] as? [String: CGFloat] {
            self.layer.shadowOffset = CGSize(
                width: shadowOffset["width"] ?? 0,
                height: shadowOffset["height"] ?? 0
            )
        }
        if let shadowRadius = style["shadowRadius"] as? CGFloat {
            self.layer.shadowRadius = shadowRadius
        }
        if let borderWidth = style["borderWidth"] as? CGFloat {
            self.layer.borderWidth = borderWidth
        }
        if let borderColor = style["borderColor"] as? UInt32 {
            self.layer.borderColor = UIColor(rgb: borderColor as UInt32).cgColor
        }
        if let clipsToBounds = style["clipsToBounds"] as? Bool {
            self.clipsToBounds = clipsToBounds
        }
        if let hidden = style["hidden"] as? Bool {
            self.isHidden = hidden
        }
        
        // Force immediate layout
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Layout pass for \(viewId)")
        print("Before yoga - Frame: \(frame), Bounds: \(bounds)")
        
        // Only apply layout if dimensions are valid
        if yoga.width.unit != .undefined && yoga.height.unit != .undefined {
            yoga.applyLayout(preservingOrigin: true)
            print("After yoga - Frame: \(frame)")
        }
    }
    
    func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        // Base event handling
    }
    
    func captureCurrentState() -> [String: Any] {
        var state: [String: Any] = [:]
        
        if alpha != 1.0 {
            state["opacity"] = alpha
            state["alpha"] = alpha
        }
        
        if isHidden {
            state["hidden"] = true
        }
        
        if let backgroundColor = backgroundColor {
            state["backgroundColor"] = backgroundColor.toARGB32()
        }
        
        if layer.cornerRadius > 0 {
            state["cornerRadius"] = layer.cornerRadius
        }
        
        if transform != .identity {
            var transformState: [String: Any] = [:]
            
            // Extract scale
            let scaleX = sqrt(transform.a * transform.a + transform.c * transform.c)
            let scaleY = sqrt(transform.b * transform.b + transform.d * transform.d)
            if scaleX != 1.0 || scaleY != 1.0 {
                transformState["scale"] = (scaleX + scaleY) / 2 // Average for simplicity
            }
            
            // Extract rotation (simplified)
            if transform.b != 0 || transform.c != 0 {
                transformState["rotation"] = atan2(transform.b, transform.a)
            }
            
            // Translation
            if transform.tx != 0 || transform.ty != 0 {
                transformState["translation"] = [
                    "x": transform.tx,
                    "y": transform.ty
                ]
            }
            
            if !transformState.isEmpty {
                state["transform"] = transformState
            }
        }
        
        return state
    }
}

